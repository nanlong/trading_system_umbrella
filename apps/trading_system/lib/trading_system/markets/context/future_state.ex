defmodule TradingSystem.Markets.FutureStateContext do
  import Ecto.Query, warn: false
  alias TradingSystem.Repo
  alias TradingSystem.Markets.FutureState
  alias TradingSystem.Markets.FuturesContext

  def create(attrs \\ %{}) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:state, FutureState.changeset(%FutureState{}, attrs))
      |> Ecto.Multi.run(:future, fn(%{state: state}) -> 
        state = Repo.preload(state, :future)

        case state.future do
          nil -> {:ok, nil}
          future -> FuturesContext.update(future, %{future_state_id: state.id})
        end
      end)
      |> Repo.transaction()
    
    case result do
      {:ok, %{state: state}} -> {:ok, state}
      {:error, :state, changeset, _} -> {:error, changeset}
    end
  end

  def list(symbol: symbol) do
    FutureState
    |> where([f], f.symbol == ^symbol)
    |> order_by([f], asc: f.date)
    |> Repo.all()
  end
end