defmodule TradingSystem.Graphql.StockStateResolver do
  alias TradingSystem.Markets

  def all(%{symbol: symbol}, _info) do
    data = Markets.list_stock_state(symbol: symbol)
    {:ok, data}
  end
end