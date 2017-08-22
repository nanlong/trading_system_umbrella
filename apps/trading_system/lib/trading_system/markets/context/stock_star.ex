defmodule TradingSystem.Markets.StockStarContext do
  
    import Ecto.Query, warn: false
    alias TradingSystem.Repo
  
    alias TradingSystem.Markets.StockStar

    def create(attrs \\ %{}) do
      %StockStar{}
      |> StockStar.changeset(attrs)
      |> Repo.insert()
    end

    def delete(symbol, user_id) do
      case Repo.get_by(StockStar, symbol: symbol, user_id: user_id) do
        nil -> {:error, nil}
        star -> Repo.delete(star)
      end
    end
  
    def include?(symbol, user_id) do
      case Repo.get_by(StockStar, symbol: symbol, user_id: user_id) do
        nil -> false
        _ -> true
      end
    end
  end