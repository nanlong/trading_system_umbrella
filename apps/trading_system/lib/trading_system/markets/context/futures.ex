defmodule TradingSystem.Markets.FuturesContext do
  import Ecto.Query, warn: false
  alias TradingSystem.Repo
  alias TradingSystem.Markets.Futures

  @i_markets ~w(CZCE DCE SHFE)
  @g_markets ~w(GLOBAL)

  def create(attrs \\ %{}) do
    %Futures{}
    |> Futures.changeset(attrs)
    |> Repo.insert()
  end

  def update(%Futures{} = future, attrs) do
    future
    |> Futures.changeset(attrs)
    |> Repo.update()
  end

  def get(symbol: symbol) do
    Repo.get_by(Futures, symbol: symbol)
  end

  def list(:i) do
    Futures
    |> where([f], f.market in @i_markets)
    |> Repo.all()
  end
  def list(:g) do
    Futures
    |> where([f], f.market in @g_markets)
    |> Repo.all()
  end
end