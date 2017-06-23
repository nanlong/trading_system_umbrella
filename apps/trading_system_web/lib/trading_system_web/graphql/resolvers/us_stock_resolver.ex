defmodule TradingSystem.Graphql.USStockResolver do
  alias TradingSystem.Repo
  alias TradingSystem.Stocks.USStockDailyPrices

  import Ecto.Query

  def all(%{symbol: symbol}, _info) do
    query =
      USStockDailyPrices
      |> where([s], s.symbol == ^symbol)
      |> order_by(asc: :date)

    {:ok, Repo.all(query)}
  end
end