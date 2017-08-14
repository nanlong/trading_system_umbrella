defmodule TradingSystem.Graphql.StockStarResolver do
  alias TradingSystem.Repo
  alias TradingSystem.Stocks
  alias TradingSystem.Stocks.StockStar
  alias TradingSystem.Stocks.StockState
  alias TradingSystem.Graphql.ErrorHelpers

  import Ecto.Query

  def all(_args, %{context: %{current_user: current_user}}) do
    date = Stocks.get_stock_state_last_date()

    results =
      StockState
      |> where([state], state.date == ^date)
      |> join(:inner, [state], star in StockStar, star.user_id == ^current_user.id and star.symbol == state.symbol)
      |> preload(:stock)
      |> Repo.all()

    {:ok, results}
  end

  def create(args, %{context: %{current_user: current_user}}) do
    changeset = StockStar.changeset(%StockStar{}, Map.put(args, :user_id, current_user.id))

    case Repo.insert(changeset) do
      {:ok, star} -> {:ok, Repo.preload(star, :stock).stock}
      {:error, changeset} -> {:error, ErrorHelpers.format_changeset(changeset)}
    end
  end

  def delete(%{symbol: symbol}, %{context: %{current_user: current_user}}) do
    case Repo.get_by(StockStar, symbol: symbol, user_id: current_user.id) do
      nil ->
        reason = "股票代码 #{symbol} 未加入到收藏"
        {:error, [message: reason, reason: reason]}
      star ->
        Repo.delete(star)
        {:ok, Repo.preload(star, :stock).stock}
    end
  end
end