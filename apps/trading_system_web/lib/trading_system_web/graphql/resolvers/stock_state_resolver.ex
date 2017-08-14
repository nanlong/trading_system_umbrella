defmodule TradingSystem.Graphql.StockStateResolver do
  alias TradingSystem.Stocks


  def all(%{symbol: symbol}, _info) do
    data = Stocks.list_stock_state(symbol: symbol)
    {:ok, data}
  end

  def all(_args, _info) do
    {:ok, Stocks.list_stock_state()}
  end
end