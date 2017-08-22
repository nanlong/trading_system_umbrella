defmodule TradingSystem.Markets.StockBlacklistContext do

  import Ecto.Query, warn: false
  alias TradingSystem.Repo

  alias TradingSystem.Markets.StockBlacklist

  def include?(symbol, user_id) do
    case Repo.get_by(StockBlacklist, symbol: symbol, user_id: user_id) do
      nil -> false
      _ -> true
    end
  end
end