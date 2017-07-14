defmodule TradingSystem.Graphql.StockDailyKResolver do
  alias TradingSystem.Stocks

  def all(%{symbol: symbol}, _info) do
    data = Stocks.list_stock_dailyk(symbol)
    {:ok, data}
  end
end