defmodule TradingSystem.Markets.StockBlacklistContext do

  import Ecto.Query, warn: false
  alias TradingSystem.Repo

  alias TradingSystem.Markets.StockBlacklist

  def create(attrs \\ %{}) do
    %StockBlacklist{}
    |> StockBlacklist.changeset(attrs)
    |> Repo.insert()
  end

  def delete(symbol, user_id) do
    case Repo.get_by(StockBlacklist, symbol: symbol, user_id: user_id) do
      nil -> {:error, nil}
      black -> Repo.delete(black)
    end
  end

  def include?(symbol, user_id) do
    case Repo.get_by(StockBlacklist, symbol: symbol, user_id: user_id) do
      nil -> false
      _ -> true
    end
  end
end