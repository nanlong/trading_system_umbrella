defmodule TradingSystem.Graphql.StockBlacklistResolver do
  alias TradingSystem.Stocks
  alias TradingSystem.Repo
  alias TradingSystem.Stocks.StockBlacklist

  import Ecto.Query

  def create(attrs, _info) do
    changeset = StockBlacklist.changeset(%StockBlacklist{}, attrs)
    
    case Repo.insert(changeset) do
      {:ok, black} -> {:ok, Repo.preload(black, :stock).stock}
      {:error, changeset} -> {:error, format_changeset(changeset)}
    end
  end

  def delete(%{symbol: symbol}, _info) do
    case  Repo.get_by(StockBlacklist, symbol: symbol) do
      nil ->
        reason = "股票代码 #{symbol} 未加入到黑名单"
        {:error, [message: reason, reason: reason]}
      black ->
        Repo.delete(black)
        {:ok, Repo.preload(black, :stock).stock}
    end
  end
  
  def format_changeset(changeset) do
    changeset.errors
    |> Enum.map(fn({key, {message, context}}) -> 
      [
        message: "#{key} #{message}",
        field: key,
        reason: message,
        details: context
      ]
    end)
  end
end