defmodule TradingSystem.Graphql.StockStarResolver do
  alias TradingSystem.Repo
  alias TradingSystem.Markets
  alias TradingSystem.Graphql.ErrorHelpers


  def create(args, %{context: %{current_user: current_user}}) do
    attrs = Map.put(args, :user_id, current_user.id)

    case Markets.create_stock_star(attrs) do
      {:ok, star} -> {:ok, Repo.preload(star, :stock).stock}
      {:error, changeset} -> {:error, ErrorHelpers.format_changeset(changeset)}
    end
  end

  def delete(%{symbol: symbol}, %{context: %{current_user: current_user}}) do
    case Markets.delete_stock_star(symbol, current_user.id) do
      {:error, _} ->
        reason = "删除失败"
        {:error, [message: reason, reason: reason]}
      {:ok, star} ->
        {:ok, Repo.preload(star, :stock).stock}
    end
  end
end