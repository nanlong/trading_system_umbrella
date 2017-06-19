defmodule TradingKernel.TrendPortfolioFilter do
  @moduledoc """
  趋势过滤器
    只有某个市场50天内的平均波幅超过了300天的平均值时，即波动出现趋势，才能考虑在这个市场做长期交易。
    而对于50天内的平均波幅低于300天均值的市场，只有小波动，就只能考虑短期交易。
  """
  alias TradingKernel.Base

  @max 300
  @min 50

  @doc """
  
  return:
    :long 适合长线交易
    :short 适合短线交易
  """
  @spec execute(list) :: :long | :short | :nothing
  def execute(results) when length(results) < @max, do: :nothing
  def execute(results) do
    tr_50 = avg_tr(results, @min)
    tr_300 = avg_tr(results, @max)
    if tr_50 > tr_300, do: :long, else: :short
  end

  defp avg_tr(results, amount) do
    results
    |> Enum.slice(-amount, amount)
    |> Enum.map(&(Base.tr(&1.pre_close_price, &1.highest_price, &1.lowest_price)))
    |> Enum.reduce(&(Decimal.add(&1, &2)))
    |> Decimal.div(Decimal.new(amount))
  end
end