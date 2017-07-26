defmodule TradingSystem.Graphql.StockBlacklistResolver do
  alias TradingSystem.Repo
  alias TradingSystem.Stocks.StockBlacklist
  alias TradingSystem.Graphql.ErrorHelpers

  def create(attrs, _info) do
    changeset = StockBlacklist.changeset(%StockBlacklist{}, attrs)
    
    case Repo.insert(changeset) do
      {:ok, black} -> {:ok, Repo.preload(black, :stock).stock}
      {:error, changeset} -> {:error, ErrorHelpers.format_changeset(changeset)}
    end
  end

  def delete(%{symbol: symbol}, _info) do
    case Repo.get_by(StockBlacklist, symbol: symbol) do
      nil ->
        reason = "股票代码 #{symbol} 未加入到黑名单"
        {:error, [message: reason, reason: reason]}
      black ->
        Repo.delete(black)
        {:ok, Repo.preload(black, :stock).stock}
    end
  end
end