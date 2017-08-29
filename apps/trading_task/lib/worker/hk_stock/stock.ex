defmodule TradingTask.Worker.HKStock.Stock do
  alias TradingApi.Sina.HKStock, as: Api 
  alias TradingSystem.Markets

  def perform(page) do 
    %{body: body} = Api.get("list", page: page)
    data = 
      (if is_nil(body), do: [], else: body)
      |> data_handler()

    Enum.map(data, fn(attrs) -> 
      %{body: body} = Api.get("detail", symbol: attrs.symbol)
      
      attrs =
        attrs
        |> Map.put(:market_cap, Map.get(body, "hk_market_cap"))
        |> Map.put(:pe, Map.get(body, "pe") |> to_string())
        |> Map.put(:lot_size, Map.get(body, "lot_size"))

      case Markets.get_stock(symbol: attrs.symbol) do
        nil -> {:ok, _} = Markets.create_stock(attrs)
        stock -> {:ok, _} = Markets.update_stock(stock, attrs)
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