defmodule TradingSystem.Graphql.StockStateResolver do
  alias TradingSystem.Stocks

  def all(_args, _info) do
    stocks = Stocks.list_stock_state()
    prices = TradingApi.get("realtime", stocks: (for stock <- stocks, do: stock.symbol))
    
    data = 
      Enum.zip(stocks, prices)
      |> Enum.map(fn({x, y}) -> Map.merge(x, y) end)
      
    {:ok, data}
  end
end