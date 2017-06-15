defmodule TradingKernel.TurtleBase do
  alias TradingKernel.Base

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