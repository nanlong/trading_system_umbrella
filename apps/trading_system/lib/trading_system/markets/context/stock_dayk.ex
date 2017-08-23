defmodule TradingSystem.Markets.StockDaykContext do
  import Ecto.Query, warn: false
  alias TradingSystem.Repo

  alias TradingSystem.Markets.StockDayk

  def create(attrs \\ %{}) do
    %StockDayk{}
    |> StockDayk.changeset(attrs)
    |> Repo.insert()
  end

  def get(symbol: symbol, date: date) do
    Repo.get_by(StockDayk, symbol: symbol, date: date)
  end

  def list(symbol: symbol) do
    StockDayk
    |> where([k], k.symbol == ^symbol)
    |> order_by([k], asc: k.date)
    |> Repo.all()
  end
end