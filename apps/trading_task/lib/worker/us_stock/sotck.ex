defmodule TradingTask.Worker.USStock.Stock do
  alias TradingApi.Sina.USStock, as: Api 
  alias TradingSystem.Markets

  def perform(page) do
    %{body: %{data: data}} = Api.get("list", page: page)
    
    Enum.map(data, fn(attrs) -> 
      attrs = Map.put(attrs, :lot_size, 1)

      case Markets.get_stock(symbol: attrs.symbol) do
        nil -> {:ok, _} = Markets.create_stock(attrs)
        stock -> {:ok, _} = Markets.update_stock(stock, attrs)
      end
      
      Exq.enqueue(Exq, "default", TradingTask.Worker.USStock.Dayk, [attrs.symbol])
    end)

    if length(data) > 0 do
      Exq.enqueue(Exq, "default", TradingTask.Worker.USStock.Stock, [page + 1])
    end
  end
end