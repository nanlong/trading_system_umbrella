defmodule TradingTask.Worker.CNStock.Stock do
  alias TradingApi, as: Api 
  alias TradingSystem.Markets

  def perform(page) do
    %{body: body} = Api.get(:cn, "list", page: page)
    data = 
      get_in(body, ["result", "data", "data"])
      |> data_handler()
    
    Enum.map(data, fn(attrs) -> 
      case Markets.get_stock(symbol: attrs.symbol) do
        nil -> {:ok, _} = Markets.create_stock(attrs)
        stock -> {:ok, _} = Markets.update_stock(stock, attrs)
      end

      Exq.enqueue(Exq, "default", TradingTask.Worker.CNStock.Dayk, [attrs.symbol])
    end)

    page_cur = get_in(body, ["result", "data", "pageCur"])
    page_num = get_in(body, ["result", "data", "pageNum"])
    page_next = page_cur + 1
    
    if page_next <= page_num do
      Exq.enqueue(Exq, "default", TradingTask.Worker.CNStock.Stock, [page_next])
    end
  end

  def data_handler(data) do
    data
    |> Enum.map(fn(x) -> 
      %{
        symbol: Map.get(x, "symbol"),
        name: get_in(x, ["ext", "name"]),
        cname: get_in(x, ["ext", "name"]),
        market: Regex.named_captures(~r/(?<market>[sh|sz]+)/, Map.get(x, "symbol")) |> Map.get("market") |> String.upcase(),
        lot_size: 100,
      }  
    end)
  end
end