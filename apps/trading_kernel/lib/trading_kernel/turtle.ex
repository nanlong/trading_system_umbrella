defmodule TradingKernel.Turtle do
  alias TradingKernel.Base
  alias TradingKernel.DonchianChannel
  alias TradingKernel.TurtleBucket
  alias TradingKernel.TrendPortfolioFilter

  @s1_in_duration 20
  @s1_out_duration 10
  @s2_in_duration 60
  @s2_out_duration 20

  def init(opts \\ []) do
    symbol = Keyword.get(opts, :symbol, "")
    history = Keyword.get(opts, :history, [])

    create_state()
    put_state(:symbol, symbol)
    put_state(:today, Date.utc_today |> Date.to_string)
    put_state(:account, 100000)
    put_state(:history, history)
    put_state(:status, TrendPortfolioFilter.execute(history))
    put_state(:donchian, DonchianChannel.execute(history, 20))
    put_state(:breakout, get_state(:donchian) |> List.last |> elem(1))
    put_state(:n, n(history, 20) |> Decimal.to_float |> Float.floor(2))
    put_state(:unit, unit(get_state(:status), get_state(:account), get_state(:n), get_state(:breakout)))
    put_state(:stop_1, stop(get_state(:status), get_state(:breakout), 1, get_state(:n)))
    put_state(:stop_2, stop(get_state(:status), get_state(:breakout), 2, get_state(:n)))
    put_state(:stop_3, stop(get_state(:status), get_state(:breakout), 3, get_state(:n)))
    put_state(:stop_4, stop(get_state(:status), get_state(:breakout), 4, get_state(:n)))
  end
  
  def create_state, do: TurtleBucket.start_link()
  def state, do: TurtleBucket.state()    
  def get_state(key), do: TurtleBucket.get(key)
  def put_state(key, value), do: TurtleBucket.put(key, value)

  # 止损
  def stop(status, breakout, position_size, n) do
    case status do
      :long -> (Map.get(breakout, :max_price) - 2 / position_size * n) |> Float.floor(2)
      :short -> (Map.get(breakout, :min_price) + 2 / position_size * n) |> Float.floor(2)
      :nothing -> 0
    end
  end

  # 头寸规模
  def unit(status, account, n, breakout) do
    case status do
      :long -> unit_price(account, n, Map.get(breakout, :max_price)) |> Float.floor(2)
      :short -> unit_price(account, n, Map.get(breakout, :min_price)) |> Float.floor(2)
      :nothing -> 0
    end
  end
  @doc """
  20天短线
  """
  def system(:one, status, stock, results) do
    {_, dc} = DonchianChannel.system(:one, results) |> Enum.at(-1)

    n =
      cond do
        status.position_size > 0 -> status.n
        true -> n(results ++ [stock])
      end
    
    up = unit_price(status.account, n, stock.bid_price)
    action = action(status, stock, dc, up, n)

    %{
      status: status,
      stock: stock,
      action: action,
    }
  end

  @doc """
  s1系统的入市点
  """
  def in_point(:s1, dt) when is_map(dt), do: %{long: dt.max_price, short: dt.min_price}
  def in_point(:s1, results) when is_list(results) do
    {_, data} = DonchianChannel.execute(results, @s1_in_duration)
    %{long: data.max_price, short: data.min_price}
  end

  @doc """
  s2系统的入市点
  """
  def in_point(:s2, dt) when is_map(dt), do: %{long: dt.max_price, short: dt.min_price}
  def in_point(:s2, results) when is_list(results) do
    {_, data} = DonchianChannel.execute(results, @s2_in_duration)
    %{long: data.max_price, short: data.min_price}
  end

  @doc """
  s1系统的退出点
  """
  def out_point(:s1, dt) when is_map(dt), do: %{long: dt.min_price, short: dt.max_price}
  def out_point(:s1, results) when is_list(results) do
    {_, data} = DonchianChannel.execute(results, @s1_out_duration)
    %{long: data.min_price, short: data.max_price}
  end

  @doc """
  s2系统的退出点
  """
  def out_point(:s2, dt) when is_map(dt), do: %{long: dt.min_price, short: dt.max_price}
  def out_point(:s2, results) when is_list(results) do
    {_, data} = DonchianChannel.execute(results, @s2_out_duration)
    %{long: data.min_price, short: data.max_price}
  end

  @doc """
  止损点
  最多损失资金的2%
  """
  def stop_point(status) do
    spread = 2 / status.position_size * status.n
    %{long: status.avg_price - spread, short: status.avg_price + spread}
  end

  @doc """
  回撤计算
    损失10%是6次
    损失20%是12次
    损失30%是18次
    损失40%是26次
    损失50%是35次
    损失60%是46次

  ## Examples

    iex> TradingKernel.Turtle.stop_loss(10000, 0.02)
    35

    iex> TradingKernel.Turtle.stop_loss(100000, 0.02)
    35

    iex> TradingKernel.Turtle.stop_loss(1000000, 0.02)
    35
  """
  def stop_loss(account, percent), do: stop_loss(account, percent, 0, account * 0.5)
  def stop_loss(account, _percent, time, limit) when account <= limit, do: time
  def stop_loss(account, percent, time, limit), do: stop_loss(account * (1 - percent), percent, time + 1, limit)

  defp action(status, stock, dc, up, n) do
    # dc 唐奇安数据
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
  def n(results, _days) when length(results) <= 20, do: Decimal.new(0)
  def n(results, days), do: n(results, days, 0, 0)
  defp n(results, days, index, pre_n) when index <= days - 1, do: n(results, days, index + 1, pre_n)
  defp n(results, _days, index, n) when index >= length(results), do: n
  defp n(results, days, index, _pre_n) when index == days do
    pre_n =
      results
      |> Enum.slice(0..index-1)
      |> Enum.map(&(item_tr(&1)))
      |> Enum.reduce(&(Decimal.add(&1, &2)))
      |> Decimal.div(Decimal.new(days))

    n(results, days, index + 1, pre_n)
  end
  defp n(results, days, index, pre_n) when index > days do
    pre_n =
      results
      |> Enum.at(index)
      |> item_atr(days, pre_n)

    n(results, days, index + 1, pre_n)
  end

  defp item_tr(item), do: Base.tr(item.pre_close_price, item.highest_price, item.lowest_price)
  defp item_atr(item, days, pre_n), do: Base.atr(pre_n, item_tr(item), days)
end