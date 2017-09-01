defmodule TradingSystem.Markets.FuturesContext do
  import Ecto.Query, warn: false
  alias TradingSystem.Repo
  alias TradingSystem.Markets.Futures

  @i_markets ~w()
  @g_markets ~w()

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

end