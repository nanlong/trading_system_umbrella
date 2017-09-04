defmodule TradingTask.Worker.GFuture.Dayk do
  alias TradingApi.Sina.GFuture, as: Api
  alias TradingSystem.Repo
  alias TradingSystem.Markets
  alias TradingSystem.Markets.FutureDayk

  def perform(symbol) do
    future = Markets.get_future(symbol: symbol)
    %{body: body} = Api.get("dayk", symbol: symbol)

    (if is_nil(body), do: [], else: body)
    |> data_handler(symbol)
    |> Enum.chunk_every(5000)
    |> Enum.map(fn(data_chunk) -> 
      {_num, results} = Repo.insert_all(FutureDayk, data_chunk, returning: true)
      future_dayk_id = results |> List.last() |> Map.get(:id)
      Markets.update_future(future, %{future_dayk_id: future_dayk_id})
    end)

    Exq.enqueue(Exq, "default", TradingTask.Worker.Future.State, [symbol])
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
          date: Map.get(x, "date") |> Date.from_iso8601!(),
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

    case Markets.list_future_dayk(symbol: symbol) |> List.last() do
      nil -> data
      dayk_last -> Enum.filter(data, &(Date.compare(&1.date, dayk_last.date) == :gt))
    end
  end

end