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


  @doc """
  唐奇安通道
  """
  def dochian_channel(data, cycle), do: dochian_channel(Enum.with_index(data), cycle, data, [])
  defp dochian_channel([], cycle, _data, results), do: {cycle, results}
  defp dochian_channel([{dayk, index} | rest], cycle, data, results) do
    pre_data = Enum.slice(data, Enum.max([index - cycle, 0])..index)
    up = 
      (for item <- pre_data, do: item.highest) 
      |> Enum.reduce(fn(x, y) -> Decimal.max(x, y) end)
    down = 
      (for item <- pre_data, do: item.lowest) 
      |> Enum.reduce(fn(x, y) -> Decimal.min(x, y) end)
    middle = 
      Decimal.sub(up, down) 
      |> Decimal.div(Decimal.new(2)) 
      |> Decimal.add(down)
      |> Decimal.round(2)
    result = %{date: dayk.date, up: up, middle: middle, down: down}
    
    dochian_channel(rest, data, cycle, results ++ [result])
  end

  @doc """
  移动平均线
  """
  def moving_average(data, cycle), do: moving_average(Enum.with_index(data), cycle, data, [])
  defp moving_average([], cycle, _data, results), do: {cycle, results}
  defp moving_average([{dayk, index} | rest], cycle, data, results) do
    pre_data = Enum.slice(data, Enum.max([index - cycle, 0])..index)
    len = if index < cycle, do: Decimal.new(index + 1), else: Decimal.new(cycle)
    value =
      (for item <- pre_data, do: item.close)
      |> Enum.reduce(fn(x, y) -> Decimal.add(x, y) end)
      |> Decimal.div(len)
      |> Decimal.round(2)
    result = %{date: dayk.date, value: value}

    moving_average(rest, cycle, data, results ++ [result])
  end

  @doc """
  真实波幅
  """
  def true_range(%{highest: highest, lowest: lowest, pre_close: pre_close}) do
    nums = [highest, lowest, pre_close]
    max = Enum.reduce(nums, fn(x, y) -> Decimal.max(x, y) end)
    min = Enum.reduce(nums, fn(x, y) -> Decimal.min(x, y) end)
    
    Decimal.sub(max, min) 
    |> Decimal.abs() 
    |> Decimal.round(2)
  end
  def true_range(data) when is_list(data), do: true_range(data, [])
  defp true_range([], results), do: results
  defp true_range([dayk | rest], results), do: true_range(rest, results ++ [%{date: dayk.date, value: true_range(dayk)}])

  @doc """
  平均真实波幅

  data 经过日期过滤 并且添加了index的数据
  results 获取之前已算过的 并经过处理的数据
  """
  def average_true_range(data, cycle, results \\ []) do
    average_true_range(data, cycle, results)
  end
  defp average_true_range([], cycle, results), do: {cycle, results}
  defp average_true_range([{dayk, index} | rest], cycle, results) do
    value =
      cond do
        index < cycle -> true_range(dayk)
        index > cycle ->
          pre_atr = Enum.at(results, index - 1) |> Map.get(:value)
          tr = true_range(dayk)

          Decimal.new(cycle)
          |> Decimal.sub(Decimal.new(1))
          |> Decimal.mult(pre_atr)
          |> Decimal.add(tr)
          |> Decimal.div(Decimal.new(cycle))
          |> Decimal.round(2)
        true -> 
          results
          |> Enum.map(fn(x) -> x.value end)
          |> Enum.reduce(fn(x, y) -> Decimal.add(x, y) end)
          |> Decimal.div(Decimal.new(cycle))
          |> Decimal.round(2)
      end
    result = %{date: dayk.date, value: value}

    average_true_range(rest, cycle, results ++ [result])
  end
end
