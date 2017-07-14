defmodule TradingSystem.Graphql.StockStateResolver do
  alias TradingSystem.Stocks


  def all(%{symbol: symbol}, _info) do
    data = Stocks.list_stock_state(symbol: symbol)
    {:ok, data}
  end

  def all(_args, _info) do
    stocks = Stocks.list_stock_state()
    prices = TradingApi.get("realtime", stocks: (for stock <- stocks, do: stock.symbol))
    random = timestamp()

    data = 
      Enum.zip(stocks, prices)
      |> Enum.map(fn({x, y}) -> Map.merge(x, y) |> Map.put_new(:random, random) end)
      
    {:ok, data}
  end

  defp timestamp, do: :os.system_time(:milli_seconds)
end