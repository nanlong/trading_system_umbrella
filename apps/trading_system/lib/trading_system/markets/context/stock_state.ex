defmodule TradingSystem.Markets.StockStateContext do
  
  import Ecto.Query, warn: false
  alias TradingSystem.Repo
  
  alias Ecto.Multi
  alias TradingSystem.Markets.StockState
  alias TradingSystem.Markets.StocksContext

  def create(attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:state, StockState.changeset(%StockState{}, attrs))
    |> Multi.run(:stock, fn(%{state: state}) -> 
      state = Repo.preload(state, :stock)
      StocksContext.update(state.stock, %{stock_state_id: state.id})
    end)
    |> Repo.transaction()
  end
end