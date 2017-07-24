defmodule TradingSystem.Graphql.StockBlacklistResolver do
  alias TradingSystem.Stocks
  alias TradingSystem.Repo
  alias TradingSystem.Stocks.StockBlacklist

  import Ecto.Query

  def create(%{symbol: symbol} = attrs, _info) do
    black = Repo.one(from b in StockBlacklist, where: [symbol: ^symbol], preload: [:stock])

    black =
      case black do
        nil ->
          changeset = StockBlacklist.changeset(%StockBlacklist{}, %{symbol: symbol})
          {:ok, black} = Repo.insert(changeset)
          Repo.preload(black, :stock)
        black -> black
      end

    {:ok, black.stock}
  end

  def delete(%{symbol: symbol}, _info) do
    stock =
      if black = Repo.one(from b in StockBlacklist, where: [symbol: ^symbol], preload: [:stock]) do
        Repo.delete(black)
        black.stock
      else
        Stocks.get_stock!(symbol)
      end
    
    {:ok, stock}
  end
end