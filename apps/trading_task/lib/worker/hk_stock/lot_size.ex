defmodule TradingTask.Worker.HKStock.LotSize do
  alias TradingApi.Sina.HKStock, as: Api
  alias TradingSystem.Markets
  require Logger

  def perform(symbol) do
    try do
      %{body: attrs} = Api.get("lotSize", symbol: symbol)
      stock = Markets.get_stock(symbol: symbol)
      {:ok, _} = Markets.update_stock(stock, attrs)
    rescue
      error ->
        Logger.error "#{symbol} logSize 接口请求错误"
        IO.inspect error
        raise "error"
    end
  end
end