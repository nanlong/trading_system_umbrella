defmodule TradingSystem.Graphql.DonchianChannel do
  alias TradingSystem.Repo
  alias TradingSystem.Stocks.USStockStatus

  import Ecto.Query

  def all(%{symbol: symbol}, _info) do
    data =
      USStockStatus
      |> where([s], s.symbol == ^symbol)
      |> order_by(asc: :date)
      |> Repo.all
      |> Enum.map(fn(x) -> 
        x
        |> Map.put_new(:high_d60, Map.get(x, :high_60))
        |> Map.put_new(:high_d20, Map.get(x, :high_20))
        |> Map.put_new(:low_d20, Map.get(x, :low_20))
        |> Map.put_new(:low_d10, Map.get(x, :low_10))
      end)
    {:ok, data}
  end
end