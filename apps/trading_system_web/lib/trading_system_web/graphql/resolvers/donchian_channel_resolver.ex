defmodule TradingSystem.Graphql.DonchianChannel do
  alias TradingSystem.Repo
  alias TradingSystem.Stocks.USStockDailyPrices
  alias TradingKernel.DonchianChannel

  import Ecto.Query

  def all(%{symbol: symbol, duration: duration}, _info) do
    data =
      USStockDailyPrices
      |> where([s], s.symbol == ^symbol)
      |> order_by(asc: :date)
      |> Repo.all
      |> DonchianChannel.execute(duration)

    {:ok, data}
  end
end