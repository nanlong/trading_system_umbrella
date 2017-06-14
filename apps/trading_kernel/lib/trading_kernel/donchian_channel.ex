defmodule TradingKernel.DonchianChannel do
  
  # 获取一段时间内的最高价
  defp max_highest_price(results) do
    Enum.max(for item <- results, do: item.highest_price)
  end

  # 获取一段时间内的最低价
  defp min_lowest_price(results) do
    Enum.min(for item <- results, do: item.lowest_price)
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