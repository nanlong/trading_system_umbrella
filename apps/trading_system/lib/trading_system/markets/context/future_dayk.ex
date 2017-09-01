defmodule TradingSystem.Markets.FutureDaykContext do
  import Ecto.Query, warn: false
  alias TradingSystem.Repo
  alias TradingSystem.Markets.FutureDayk
  alias TradingSystem.Markets.FuturesContext

  def create(attrs \\ %{}) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:dayk, FutureDayk.changeset(%FutureDayk{}, attrs))
      |> Ecto.Multi.run(:future, fn(%{dayk: dayk}) -> 
        dayk = Repo.preload(dayk, :future)

        case dayk.future do
          nil -> {:ok, nil}
          future -> FuturesContext.update(future, %{future_dayk_id: dayk.id})
        end
      end)
      |> Repo.transaction()
    
    case result do
      {:ok, %{dayk: dayk}} -> {:ok, dayk}
      {:error, :dayk, changeset, _} -> {:error, changeset}
    end
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