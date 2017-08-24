defmodule TradingTask.Worker.HKStock.Stock do
  alias TradingApi, as: Api 
  alias TradingSystem.Markets

  def perform(page) do 
    %{body: body} = Api.get(:hk, "list", page: page)
    data = 
      (if is_nil(body), do: [], else: body)
      |> data_handler()

    Enum.map(data, fn(attrs) -> 
      case Markets.get_stock(symbol: attrs.symbol) do
        nil -> 
          {:ok, _} = Markets.create_stock(attrs)
        stock -> 
          attrs = if not is_nil(stock.lot_size), do: Map.delete(attrs, :lot_size), else: attrs
          {:ok, _} = Markets.update_stock(stock, attrs)
      end

      Exq.enqueue(Exq, "default", TradingTask.Worker.HKStock.Dayk, [attrs.symbol])
    end)

    if not is_nil(body) do
      Exq.enqueue(Exq, "default", TradingTask.Worker.HKStock.Stock, [page + 1])
    end
  end

  def data_handler(data) do
    data
    |> Enum.map(fn(x) -> 
      %{
        symbol: Map.get(x, "symbol"),
        name: Map.get(x, "engname"),
        cname: Map.get(x, "name"),
        market: "HK",
        lot_size: 1,
      }
    end)
  end
end