defmodule TradingSystem.Markets.FutureDaykContext do
  import Ecto.Query, warn: false
  alias TradingSystem.Repo
  alias TradingSystem.Markets.FutureDayk

  def create(attrs \\ %{}) do
    %FutureDayk{}
    |> FutureDayk.changeset(attrs)
    |> Repo.insert()
  end

  def get(symbol: symbol, date: date) do
    Repo.get_by(FutureDayk, symbol: symbol, date: date)
  end

  def list(symbol: symbol) do
    FutureDayk
    |> where([f], f.symbol == ^symbol)
    |> order_by([f], asc: f.date)
    |> Repo.all()
  end
end