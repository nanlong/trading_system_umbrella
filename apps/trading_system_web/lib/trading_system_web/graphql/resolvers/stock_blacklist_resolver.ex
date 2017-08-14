defmodule TradingSystem.Graphql.StockBlacklistResolver do
  alias TradingSystem.Repo
  alias TradingSystem.Stocks.StockBlacklist
  alias TradingSystem.Graphql.ErrorHelpers

  def create(args, %{context: %{current_user: current_user}}) do
    changeset = StockBlacklist.changeset(%StockBlacklist{}, Map.put(args, :user_id, current_user.id))
    
    case Repo.insert(changeset) do
      {:ok, black} -> {:ok, Repo.preload(black, :stock).stock}
      {:error, changeset} -> {:error, ErrorHelpers.format_changeset(changeset)}
    end
  end

  def delete(%{symbol: symbol}, %{context: %{current_user: current_user}}) do
    case Repo.get_by(StockBlacklist, symbol: symbol, user_id: current_user.id) do
      nil ->
        reason = "股票代码 #{symbol} 未加入到黑名单"
        {:error, [message: reason, reason: reason]}
      black ->
        Repo.delete(black)
        {:ok, Repo.preload(black, :stock).stock}
    end
  end
end