defmodule TradingKernel.Turtle do
  alias TradingKernel.Base
  alias TradingKernel.DonchianChannel

  @doc """
  20天短线
  """
  def system(:one, status, stock, results) do
    {_, dc} = DonchianChannel.system(:one, results) |> Enum.at(-1)

    atr =
      cond do
        status.position_size > 0 -> status.n
        true -> n(results ++ [stock])
      end

    up = unit_price(status.account, atr, stock.bid_price)
    action = action(status, stock, dc, up, atr)

    %{
      status: status,
      stock: stock,
      action: action,
    }
  end

  @doc """
  55天长线
  """
  def system(:two, status, stock) do
    
  end

  defp action(status, stock, dc, up, n) do
    # account 资金总量
    # max_position_size 最大仓位
    # position_size 当前仓规模
    # avg_price 当前仓平均价
    # bid_price 股票买入价格
    # ask_price 股票卖出价格
    # max_price 唐奇安最高价
    # min_price 唐奇安最低价
    # up 单位价格
    # n

    cond do
      # 建仓
      status.position_size == 0 and stock.bid_price > dc.max_price -> :op
      # 加仓
      status.position_size > 0 and status.position_size < status.max_position_size and stock.bid_price > (dc.max_price + 0.5 * n) and status.account > up -> :ap
      # 止损平仓
      status.position_size > 0 and stock.ask_price < (status.avg_price - 2 / status.position_size * n) -> :cp
      # 止盈平仓
      status.position_size > 0 and stock.ask_price < dc.min_price -> :cp
      #  默认
      true -> :nothing
    end
  end

  defp unit_price(account, n, price) do
    # 计算头寸资金
    # account 总资金
    # n 当天n值
    # price 股票价格
    Base.unit(account, n) * price
  end

  def n(results, days \\ 20)
  def n(results, _days) when length(results) <= 20, do: 0.0
  def n(results, days), do: n(results, days, 0, 0)
  def n(results, days, index, pre_n) when index <= days - 1, do: n(results, days, index + 1, pre_n)
  def n(results, _days, index, n) when index >= length(results), do: n
  def n(results, days, index, _pre_n) when index == days do
    pre_n =
      results
      |> Enum.slice(0..index-1)
      |> Enum.map(&(item_tr(&1)))
      |> Enum.reduce(&(Decimal.add(&1, &2)))
      |> Decimal.div(Decimal.new(days))

    n(results, days, index + 1, pre_n)
  end
  def n(results, days, index, pre_n) when index > days do
    pre_n =
      results
      |> Enum.at(index)
      |> item_atr(days, pre_n)

    n(results, days, index + 1, pre_n)
  end

  defp item_tr(item), do: Base.tr(item.pre_close_price, item.highest_price, item.lowest_price)
  defp item_atr(item, days, pre_n), do: Base.atr(pre_n, item_tr(item), days)
end