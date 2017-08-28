defmodule TradingTask.Worker.HKStock.Dayk do
  alias TradingApi.Sina.HKStock, as: Api
  alias TradingSystem.Repo
  alias TradingSystem.Markets
  alias TradingSystem.Markets.StockDayk
  require Logger

  def perform(symbol) do
    try do
      stock = Markets.get_stock(symbol: symbol)
      %{body: body} = Api.get("dayk", symbol: symbol)
      
      (if is_nil(body), do: [], else: body)
      |> data_handler(symbol)
      |> Enum.chunk_every(5000)
      |> Enum.map(fn(data_chunk) -> 
        {_num, results} = Repo.insert_all(StockDayk, data_chunk, returning: true)
        stock_dayk_id = results |> List.last() |> Map.get(:id)
        Markets.update_stock(stock, %{stock_dayk_id: stock_dayk_id})
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
          volume: Map.get(x, "volume"),
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