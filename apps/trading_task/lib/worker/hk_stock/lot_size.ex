defmodule TradingTask.Worker.HKStock.LotSize do
  alias TradingApi, as: Api
  alias TradingSystem.Markets

  def perform(symbol) do
    %{body: attrs} = Api.get(:hk, "lotSize", symbol: symbol)
    {:ok, _} = Markets.update_stock(stock, attrs)
  end
end