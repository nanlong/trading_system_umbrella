defmodule TradingKernel.DonchianChannel do

  @doc """
  唐奇安通道的两个系统，分别为20天和55天
  """
  def system(:one, results), do: execute(results, 20)
  def system(:two, results), do: execute(results, 55)

  @doc """
  唐奇安通道

  ## Examples:
    iex> TradingKernel.DonchianChannel.execute([], 20)
    []
  """
  def execute(results, days) when length(results) <= days, do: []
  def execute(results, days), do: execute(results, days, 0, [])
  def execute(results, days, index, resp) when index <= days - 1, do: execute(results, days, index + 1, resp)
  def execute(results, _days, index, resp) when index == length(results), do: resp
  def execute(results, days, index, resp) do
    current = Enum.at(results, index)
    start_index = index - days
    end_index = start_index + days
    before_results = Enum.slice(results, start_index..end_index)
    max = max_highest_price(before_results)
    min = min_lowest_price(before_results)
    mid = mid_price(max, min)
    resp = resp ++ [{current.date, %{max: max, min: min, mid: mid}}]
    execute(results, days, index + 1, resp)
  end
  
  # 获取一段时间内的最高价
  defp max_highest_price(results) do
    (for item <- results, do: item.highest_price)
    |> Enum.max
    |> Decimal.new
  end

  # 获取一段时间内的最低价
  defp min_lowest_price(results) do
    (for item <- results, do: item.lowest_price)
    |> Enum.min
    |> Decimal.new
  end

  # 获取中间价
  defp mid_price(max, min) when is_float(max) or is_float(min) do
    max = Decimal.new(max)
    min = Decimal.new(min)
    mid_price(max, min)
  end
  defp mid_price(max, min) do
    max
    |> Decimal.sub(min)
    |> Decimal.div(Decimal.new(2))
    |> Decimal.add(min)
  end
end