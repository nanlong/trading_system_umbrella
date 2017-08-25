defmodule TradingTask.Worker.HKStock.LotSize do
  alias TradingApi.Sina.HKStock, as: Api
  alias TradingSystem.Markets

  def perform(symbol) do
    %{body: attrs} = Api.get("lotSize", symbol: symbol)
    stock = Markets.get_stock(symbol: symbol)
    {:ok, _} = Markets.update_stock(stock, attrs)
  end
end