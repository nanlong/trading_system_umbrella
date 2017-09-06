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

  def get(symbol: symbol, date: date) do
    StockState
    |> where([s], s.symbol == ^symbol)
    |> where([s], s.date == ^date)
    |> Repo.one()
  end

  def list(symbol: symbol) do
    StockState
    |> where([s], s.symbol == ^symbol)
    |> order_by([s], asc: s.date)
    |> Repo.all()
  end
end