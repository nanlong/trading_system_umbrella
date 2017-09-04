defmodule TradingTask.Worker.GFuture.List do
  alias TradingApi.Sina.GFuture, as: Api
  alias TradingSystem.Markets

  def perform do
    %{body: body} = Api.get("list")
    
    get_in(body, ["result", "data", "global_good"])
    |> data_handler()
    |> Enum.map(fn(attrs) -> 
      {:ok, future} =
        case Markets.get_future(symbol: attrs.symbol) do
          nil -> Markets.create_future(attrs)
          future -> {:ok, future}
        end
      
      Exq.enqueue(Exq, "default", TradingTask.Worker.GFuture.Detail, [future.symbol])
      Exq.enqueue(Exq, "default", TradingTask.Worker.GFuture.Dayk, [future.symbol])
    end)
  end

  def data_handler(data) do
    Enum.map(data, fn(x) -> 
      %{
        symbol: Map.get(x, "symbol"),
        name: "占位更新",
        market: "GLOBAL",
      }
    end)
  end
end