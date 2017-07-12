defmodule TradingSystem.Graphql.USStockResolver do
  alias TradingSystem.Repo
  alias TradingSystem.Stocks.StockDailyK

  import Ecto.Query

  def all(%{symbol: symbol}, _info) do
    query =
      StockDailyK
      |> where([s], s.symbol == ^symbol)
      |> order_by(asc: :date)

    {:ok, Repo.all(query)}
  end

  def realtime(%{stocks: stocks}, _info) do
    stocks = stocks |> String.split(",") |> Enum.map(&(String.trim(&1) |> String.replace(".", "$")))
    {:ok, TradingApi.get("realtime", stocks: stocks)}
  end
end