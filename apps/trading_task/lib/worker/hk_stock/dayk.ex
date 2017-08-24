defmodule TradingTask.Worker.HKStock.Dayk do
  alias TradingApi, as: Api
  alias TradingSystem.Markets
  require Logger

  def perform(symbol) do
    Logger.info "#{symbol} 日K数据"
    %{body: body} = Api.get(:hk, "dayk", symbol: stock.symbol)
    
    (if is_nil(body), do: [], else: body)
    |> data_handler(symbol)
    |> Enum.map(data, fn(attrs) -> {:ok, _} =Markets.create_stock_dayk(attrs) end)

    Exq.enqueue(Exq, "default", TradingTask.Worker.StockState, [symbol])
  end

  def data_handler(data, symbol) do 
    data = Enum.map(data, fn(x) -> 
      pre_close =
        if index > 0 do
          dayk_list |> Enum.at(index - 1) |> Map.get("close")
        else
          x |> Map.get("close")
        end
      
      {:ok, datetime, _} =
        x
        |> Map.get("date")
        |> DateTime.from_iso8601()
      
      date = DateTime.to_date(datetime)

      %{
        date: date,
        symbol: symbol,
        open: Map.get(x, "open"),
        highest: Map.get(x, "high"),
        lowest: Map.get(x, "low"),
        close: Map.get(x, "close"),
        pre_close: pre_close,
        volume: Map.get(x, "volume")
      }
    end)
    
    case Markets.list_stock_dayk(symbol: stock.symbol) |> List.last() do
      nil -> data
      dayk_last -> Enum.filter(data, &(Date.compare(&1.date, dayk_last.date) == :gt))
    end
  end
end