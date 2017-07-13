defmodule TradingKernel.DonchianChannel do

  # 获取一段时间内的最高价
  def up(results) do
    (for item <- results, do: item.highest)
    |> Enum.reduce(fn(x, y) -> Decimal.max(x, y) end)
  end

  # 获取一段时间内的最低价
  def lower(results) do
    (for item <- results, do: item.lowest)
    |> Enum.reduce(fn(x, y) -> Decimal.min(x, y) end)
  end

  def avg(max, min) do
    max
    |> Decimal.sub(min)
    |> Decimal.div(Decimal.new(2))
    |> Decimal.add(min)
    |> Decimal.round(2)
  end
end