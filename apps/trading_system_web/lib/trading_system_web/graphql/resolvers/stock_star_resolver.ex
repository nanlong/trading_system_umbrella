defmodule TradingSystem.Graphql.StockStarResolver do
  alias TradingSystem.Repo
  alias TradingSystem.Stocks
  alias TradingSystem.Stocks.StockStar
  alias TradingSystem.Stocks.StockState
  alias TradingSystem.Graphql.ErrorHelpers

  import Ecto.Query

  def all(_args, _info) do
    date = Stocks.get_stock_state_last_date()

    results =
      StockState
      |> where([state], state.date == ^date)
      |> join(:inner, [state], star in StockStar, star.symbol == state.symbol)
      |> preload(:stock)
      |> Repo.all()

    {:ok, results}
  end

  def create(attrs, _info) do
    changeset = StockStar.changeset(%StockStar{}, attrs)

    case Repo.insert(changeset) do
      {:ok, star} -> {:ok, Repo.preload(star, :stock).stock}
      {:error, changeset} -> {:error, ErrorHelpers.format_changeset(changeset)}
    end
  end

  def delete(%{symbol: symbol}, _info) do
    case Repo.get_by(StockStar, symbol: symbol) do
      nil ->
        reason = "股票代码 #{symbol} 未加入到收藏"
        {:error, [message: reason, reason: reason]}
      star ->
        Repo.delete(star)
        {:ok, Repo.preload(star, :stock).stock}
    end
  end
end