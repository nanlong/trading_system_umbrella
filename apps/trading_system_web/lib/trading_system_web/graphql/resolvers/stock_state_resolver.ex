defmodule TradingSystem.Graphql.USStockStateResolver do
  alias TradingSystem.Stocks

  def all(_args, _info) do
    stocks = Stocks.list_stock_state()
    prices = TradingApi.get("realtime", stocks: (for stock <- stocks, do: stock.symbol))

    data = []
      
    {:ok, data}
  end
end