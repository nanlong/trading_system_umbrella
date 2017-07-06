defmodule TradingKernel.DonchianChannel do

  @doc """
  唐奇安通道的两个系统，分别为20天和60天
  """
  @spec system(:one | :two, list) :: list
  def system(:one, results), do: execute(results, 20)
  def system(:two, results), do: execute(results, 60)

  @doc """
  唐奇安通道

  ## Examples:
    iex> TradingKernel.DonchianChannel.execute([], 20)
    [%{date: ~D[0000-01-01], max_price: 0, mid_price: 0, min_price: 0}]
  """
  def execute(results, days) when length(results) <= days, do: [%{date: ~D[0000-01-01], high: 0, low: 0, avg: 0}]
  def execute(results, days), do: execute(results, days, 0, [])
  defp execute(results, days, index, resp) when index <= days - 1, do: execute(results, days, index + 1, resp)
  defp execute(results, _days, index, resp) when index == length(results), do: resp
  defp execute(results, days, index, resp) do
    current = Enum.at(results, index)
    start_index = index - days
    end_index = start_index + days - 1
    before_results = Enum.slice(results, start_index..end_index)
    max = max_highest_price(before_results) |> Decimal.to_float
    min = min_lowest_price(before_results) |> Decimal.to_float
    mid = mid_price(max, min) |> Decimal.to_float
    resp = resp ++ [%{date: current.date, high: max, low: min, avg: mid}]
    execute(results, days, index + 1, resp)
  end
  
  # 获取一段时间内的最高价
  def max_highest_price(results) do
    (for item <- results, do: Decimal.to_float(item.highest_price))
    |> Enum.max
    |> Decimal.new
  end

  # 获取一段时间内的最低价
  def min_lowest_price(results) do
    (for item <- results, do: Decimal.to_float(item.lowest_price))
    |> Enum.min
    |> Decimal.new
  end

  # 获取中间价
  def mid_price(max, min) when is_float(max) or is_float(min) do
    max = Decimal.new(max)
    min = Decimal.new(min)
    mid_price(max, min)
  end
  def mid_price(max, min) do
    max
    |> Decimal.sub(min)
    |> Decimal.div(Decimal.new(2))
    |> Decimal.add(min)
  end
end