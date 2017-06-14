defmodule TradingKernel do
  @moduledoc """
  Documentation for TradingKernel.
  """
  alias TradingKernel.Base

  def n(results, days \\ 20)
  def n(results, _days) when length(results) <= 20, do: 0.0
  def n(results, days), do: n(results, days, 0, 0)
  def n(results, days, index, pre_n) when index <= days - 1, do: n(results, days, index + 1, pre_n)
  def n(results, _days, index, n) when index >= length(results), do: n
  def n(results, days, index, _pre_n) when index == days do
    before_results = Enum.slice(results, 0..index-1)
    tr_list = Enum.map(before_results, fn item -> Base.tr(item.pre_close_price, item.highest_price, item.lowest_price) end)
    
    pre_n =
      Enum.reduce(tr_list, &(Decimal.add(&1, &2)))
      |> Decimal.div(Decimal.new(days))

    n(results, days, index + 1, pre_n)
  end
  def n(results, days, index, pre_n) when index > days do
    item = Enum.at(results, index)
    item_tr = Base.tr(item.pre_close_price, item.highest_price, item.lowest_price)
    pre_n = Base.atr(pre_n, item_tr, days)
    n(results, days, index + 1, pre_n)
  end
end
