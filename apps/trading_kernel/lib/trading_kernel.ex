defmodule TradingKernel do
  @moduledoc """
  Documentation for TradingKernel.
  """
  alias TradingKernel.Common

  @doc """
  真实波幅

  ## Example:
    iex> data = %{pre_close: Decimal.new(18.96), highest: Decimal.new(19.14), lowest: Decimal.new(18.98)}
    iex> TradingKernel.tr(data)
    #Decimal<0.18>
  """
  def tr(%{pre_close: pc, highest: h, lowest: l}) do
    Common.tr(pc, h, l)
  end

  @doc """
  唐奇安通道

  ## Example:
    iex> h1 = %{highest: Decimal.new(18.6), lowest: Decimal.new(18.57)}
    iex> h2 = %{highest: Decimal.new(19.24), lowest: Decimal.new(19.14)}
    iex> h3 = %{highest: Decimal.new(19.14), lowest: Decimal.new(18.98)}
    iex> TradingKernel.dc([h1, h2, h3], 3)
    %{avg: Decimal.new(18.91), lower: Decimal.new(18.57), up: Decimal.new(19.24)}
    iex> TradingKernel.dc([h1, h2, h3], 2)
    %{avg: Decimal.new(19.11), lower: Decimal.new(18.98), up: Decimal.new(19.24)}
  """
  def dc(history, duration) when length(history) > duration do
    history = list_slice(history, duration)
    dc(history, duration)
  end
  def dc(history, _duration) do
    up = Common.dc_up(history)
    lower = Common.dc_lower(history)
    avg = Common.dc_avg(up, lower)
    
    %{up: up, avg: avg, lower: lower}
  end

  @doc """
  移动平均

  ## Example:
    iex> history = [%{close: Decimal.new(5)}, %{close: Decimal.new(4)}, %{close: Decimal.new(3)}]
    iex> TradingKernel.ma(history, 3)
    #Decimal<4.00>
    iex> TradingKernel.ma(history, 2)
    #Decimal<3.50>
  """
  def ma(history, duration) when length(history) > duration do
    history = list_slice(history, duration)
    ma(history, duration)
  end
  def ma(history, _duration) do
    len = history |> length() |> Decimal.new()

    (for item <- history, do: item.close)
    |> Enum.reduce(fn(x, y) -> Decimal.add(x, y) end)
    |> Decimal.div(len)
    |> Decimal.round(2)
  end

  defp list_slice(list, range_end) do
    list
    |> Enum.reverse() 
    |> Enum.slice(0..range_end - 1) 
    |> Enum.reverse()
  end

  @doc """
  头寸单位

  ## Example:
    iex> state = %{atr20: Decimal.new(2.76)}
    iex> TradingKernel.unit(10000, state)
    18
  """
  def unit(account, %{atr20: atr}, percent \\ 0.5) do
    Common.unit(account, Decimal.to_float(atr), percent)
  end
end
