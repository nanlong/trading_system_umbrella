defmodule TradingTask.Worker.CNStock.Dayk do
  alias TradingApi, as: Api

  def perform(symbol) do
    %{body: body} = Api.get(:cn, "dayk", symbol: stock.symbol)
    data = if is_nil(body), do: [], else: body
    data = data_handler(symbol, data)

    Enum.map(data, fn(attrs) ->  Markets.create_stock_dayk(attrs) end)
    Exq.enqueue(Exq, "default", TradingTask.Worker.CNStock.State, [symbol])
  end

  def data_handler(symbol, data) do
    data = 
      data
      |> Enum.with_index()
      |> Enum.map(fn({x, index}) -> 
        pre_close =
          if index > 0 do
            dayk_list |> Enum.at(index - 1) |> Map.get("close")
          else
            x |> Map.get("close")
          end

          %{
            date: Map.get(x, "day"),
            symbol: symbol,
            open: Map.get(x, "open"),
            highest: Map.get(x, "high"),
            lowest: Map.get(x, "low"),
            close: Map.get(x, "close"),
            pre_close: pre_close,
            volume: Map.get(x, "volume")
          }
      end)
    
    case Markets.list_stock_dayk(symbol: symbol) |> List.last() do
      nil -> data
      dayk_last -> Enum.filter(data, &(Date.compare(Date.from_iso8601!(&1.date), dayk_last.date) == :gt))
    end
  end
end