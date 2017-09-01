defmodule TradingTask.Worker.IFuture.LotSize do
  alias TradingApi.Sina.IFuture, as: Api
  alias TradingSystem.Markets
  require Logger

  def perform(symbol) do
    case Markets.get_future(symbol: symbol) do
      nil -> nil
      future ->
        %{body: body} = Api.get("lotSize", symbol: symbol, timeout: 10_000)

        if is_nil(body) do
          Logger.debug "get lot_size error #{symbol}"
        else
          lot_size = Map.get(body, "lot_size")
          {:ok, _} = Markets.update_future(future, %{lot_size: lot_size})
        end
    end
  end
end