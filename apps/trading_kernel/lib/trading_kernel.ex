defmodule TradingKernel do
  @moduledoc """
  Documentation for TradingKernel.
  """
  alias TradingSystem.Stocks
  alias TradingKernel.Base
  alias TradingKernel.TurtleBase
  alias TradingKernel.DonchianChannel

  @doc """
  return %{
    
  }

  1. 唐奇安
  2. 计算当前n值
  3. 判断行为
  4. 更新状态
  """
  def turtle(status, stock) do
    results = Stocks.list_us_stock_daily_prices(stock.symbol, stock.date, 1741) |> Enum.reverse

    {dc_date, dc_data} = DonchianChannel.system(:one, results) |> Enum.at(-1)
    
    n =
      cond do
        status.cur_position > 0 -> status.n
        true -> TurtleBase.n(results ++ [stock])
      end
    
    stock_price = Decimal.to_float(stock.price)

    position_price = Base.unit(status.account, n) * stock_price

    # op -> open position 建仓
    # ap -> add position 加仓
    # cp -> close position 平仓
    action =
      cond do
        # 建仓
        status.cur_position == 0 and stock_price > dc_data.max -> :op
        # 加仓
        status.cur_position > 0 and status.cur_position <= status.max_position and stock_price > (dc_data.max + n * 0.5) and status.account > position_price -> :ap
        # 止损平仓
        status.cur_position > 0 and stock_price < (status.avg_price - 2 / status.cur_position * status.n) -> :cp
        # 止盈平仓
        status.cur_position > 0 and stock_price < dc_data.min -> :cp
        # 默认
        true -> :nothing
      end

    IO.inspect dc_data
    IO.inspect action
    IO.inspect n
  end
end
