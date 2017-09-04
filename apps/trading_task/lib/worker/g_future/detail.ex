defmodule TradingTask.Worker.GFuture.Detail do
  alias TradingApi.Sina.GFuture, as: Api
  alias TradingSystem.Markets
  require Logger

  def perform(symbol) do
    case Markets.get_future(symbol: symbol) do
      nil -> nil
      future ->
        %{body: body} = Api.get("detail", symbol: symbol, timeout: 10_000)

        if is_nil(body) do
          Logger.debug "get detail error #{symbol}"
        else
          name = Map.get(body, "name")
          lot_size = Map.get(body, "lot_size")
          {:ok, _} = Markets.update_future(future, %{name: name, lot_size: lot_size})
        end
    end
  end
end