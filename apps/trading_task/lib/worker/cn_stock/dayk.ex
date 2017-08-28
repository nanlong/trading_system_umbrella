defmodule TradingTask.Worker.CNStock.Dayk do
  # Exq.enqueue(Exq, "default", TradingTask.Worker.CNStock.Dayk, ["sh601677"])
  alias TradingApi.Sina.CNStock, as: Api 
  alias TradingSystem.Repo
  alias TradingSystem.Markets
  alias TradingSystem.Markets.StockDayk
  require Logger

  def perform(symbol) do
    try do
      %{body: body} = Api.get("dayk", symbol: symbol)

      (if is_nil(body), do: [], else: body)
      |> data_handler(symbol)
      |> Enum.chunk_every(5000)
      |> Enum.map(fn(data_chunk) -> 
        Repo.insert_all(StockDayk, data_chunk)
      end)

      Exq.enqueue(Exq, "default", TradingTask.Worker.Stock.State, [symbol])
    rescue
      error ->
        Logger.error "#{symbol} dayk 接口请求错误"
        IO.inspect error
        raise "error"
    end
  end

  def data_handler(data, symbol) do
    data = 
      data
      |> Enum.with_index()
      |> Enum.map(fn({x, index}) -> 
        pre_close =
          if index > 0 do
            data |> Enum.at(index - 1) |> Map.get("close")
          else
            x |> Map.get("close")
          end
          
          %{
            date: Map.get(x, "day") |> Date.from_iso8601!(),
            symbol: symbol,
            open: Map.get(x, "open") |> String.to_float(),
            highest: Map.get(x, "high") |> String.to_float(), 
            lowest: Map.get(x, "low") |> String.to_float(),
            close: Map.get(x, "close") |> String.to_float(),
            pre_close: pre_close |> String.to_float(),
            volume: Map.get(x, "volume") |> String.to_integer(),
            inserted_at: NaiveDateTime.utc_now(),
            updated_at: NaiveDateTime.utc_now(),
          }
      end)
    
    case Markets.list_stock_dayk(symbol: symbol) |> List.last() do
      nil -> data
      dayk_last -> Enum.filter(data, &(Date.compare(&1.date, dayk_last.date) == :gt))
    end
  end
end