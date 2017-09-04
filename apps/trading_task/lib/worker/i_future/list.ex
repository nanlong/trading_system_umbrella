defmodule TradingTask.Worker.IFuture.List do
  alias TradingApi.Sina.IFuture, as: Api
  alias TradingSystem.Markets

  def perform do
    %{body: body} = Api.get("list")
    czce = get_in(body, ["result", "data", "czce"])
    dce = get_in(body, ["result", "data", "dce"])
    shfe = get_in(body, ["result", "data", "shfe"])

    Enum.concat([czce, dce, shfe])
    |> data_handler()
    |> Enum.map(fn(attrs) -> 
      {:ok, future} =
        case Markets.get_future(symbol: attrs.symbol) do
          nil -> Markets.create_future(attrs)
          future -> {:ok, future}
        end
      
      Exq.enqueue(Exq, "default", TradingTask.Worker.IFuture.Detail, [future.symbol])
      Exq.enqueue(Exq, "default", TradingTask.Worker.IFuture.Dayk, [future.symbol])
    end)
  end

  def data_handler(data) do
    Enum.map(data, fn(x) -> 
      %{
        symbol: Map.get(x, "symbol"),
        name: Map.get(x, "contract"),
        market: Map.get(x, "market") |> String.upcase(),
      }
    end)
  end
end