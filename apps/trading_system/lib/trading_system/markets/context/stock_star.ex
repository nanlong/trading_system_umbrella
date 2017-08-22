defmodule TradingSystem.Markets.StockStarContext do
  
    import Ecto.Query, warn: false
    alias TradingSystem.Repo
  
    alias TradingSystem.Markets.StockStar
  
    def include?(symbol, user_id) do
      case Repo.get_by(StockStar, symbol: symbol, user_id: user_id) do
        nil -> false
        _ -> true
      end
    end
  end