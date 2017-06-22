defmodule TradingKernel.MockTrading do
  @moduledoc """
  模拟交易 使用s1系统规则，s2系统不需要模拟交易
  """
  alias TradingKernel.Turtle
  alias TradingKernel.DonchianChannel
  @doc """
  return: boolean
  true -> 可以交易 
  false -> 放弃交易
  """
  def execute do
    if Turtle.state_has_key?(:trading?) do
      Turtle.get_state(:trading?)
    else
      history = Turtle.get_state(:history)
      min_history = Turtle.get_state(:min_history)
      donchian_20 = Turtle.get_state(:donchian)
      donchian_10 = DonchianChannel.execute(history, 10)
      execute(history, Enum.reverse(min_history), donchian_20, donchian_10)
    end
  end

  def execute(_, [], _, _), do: false
  def execute(history, [min_data | rest], donchian_20, donchian_10) do
    %{max_price: max_price, min_price: min_price} = Keyword.get(donchian_20, min_data.date)
    
    # 这个时间点之后的分钟数据
    {_, after_data} = Enum.split_with(Turtle.get_state(:min_history), &(&1.datetime < min_data.datetime))
    
    # 这个时间点之前的日数据
    {before_data, _} = Enum.split_with(history, &(&1.date < min_data.date))
    n = Turtle.n(before_data)

    cond do
      # 做多
      min_data.price > max_price ->
        trading(:long, min_data.date, min_data.price, n, history, after_data, donchian_10)
      # 做空
      min_data.price < min_price -> 
        trading(:short, min_data.date, min_data.price, n, history, after_data, donchian_10)
      # 检查下一个价格
      true -> execute(history, rest, donchian_20, donchian_10)
    end
  end

  @doc """
  执行做多交易
  """
  def trading(:long, _date, _position_price, _n, _history, [], _donchian_10), do: false
  def trading(:long, date, position_price, n, history, [min_data, rest], donchian_10) do
    sp = position_price - 2 * n
    cp = Keyword.get(donchian_10, date) |> elem(1) |> Map.get(:min_price)

    cond do
      min_data.price < cp -> position_price < cp and cp - position_price >= 2 * n
      min_data.price < sp -> true
      true -> trading(:long, min_data.date, position_price, n, history, rest, donchian_10)
    end
  end

  @doc """
  执行做空交易
  """
  def trading(:short, _date, _position_price, _n, _history, [], _donchian_10), do: false
  def trading(:short, date, position_price, n, history, [min_data, rest], donchian_10) do
    sp = position_price - 2 * n
    cp = Keyword.get(donchian_10, date) |> elem(1) |> Map.get(:min_price)
    
    cond do
      min_data.price > cp -> position_price > cp and position_price - cp >= 2 * n
      min_data.price > sp -> true
      true -> trading(:long, min_data.date, position_price, n, history, rest, donchian_10)
    end
  end
end