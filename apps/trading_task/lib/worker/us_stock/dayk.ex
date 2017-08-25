defmodule TradingTask.Worker.USStock.Dayk do
  alias TradingApi.Sina.USStock, as: Api 
  alias TradingSystem.Markets
  require Logger

  def perform(symbol) do
    Logger.info "#{symbol} 日K数据"
    %{body: body} = Api.get("dayk", symbol: symbol)
    
    (if is_nil(body), do: [], else: body)
    |> data_handler(symbol)
    |> Enum.map(fn(attrs) -> {:ok, _} = Markets.create_stock_dayk(attrs) end)

    Exq.enqueue(Exq, "default", TradingTask.Worker.Stock.State, [symbol])
  end

  def data_handler(data, symbol) do
    data =
      data
      |> Enum.with_index()
      |> Enum.map(fn({x, index}) -> 
        pre_close =
          if index > 0 do
            data |> Enum.at(index - 1) |> Map.get(:close)
          else
            x |> Map.get(:close)
          end
        
        x
        |> Map.put(:symbol, symbol)
        |> Map.put(:pre_close, pre_close)
      end)

    case Markets.list_stock_dayk(symbol: symbol) |> List.last() do
      nil -> data
      dayk_last -> Enum.filter(data, &(Date.compare(Date.from_iso8601!(&1.date), dayk_last.date) == :gt))
    end
  end
end