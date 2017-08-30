defmodule TradingSystem.Graphql.StockResolver do
  alias TradingSystem.Markets

  def get(%{symbol: symbol}, _info) do
    {:ok, Markets.get_stock!(symbol: symbol)}
  end

  def realtime(%{stocks: stocks}, _info) do
    stocks = 
      stocks 
      |> String.split(",") 
      |> Enum.map(&(String.trim(&1) 
      |> String.replace(".", "$")))
    
    data = 
      TradingApi.get(:us, "realtime", stocks: stocks)
      |> Map.get(:body)
      |> Enum.map(fn(x) -> Map.put_new(x, :random, :os.system_time()) end)

    {:ok, data}
  end
end