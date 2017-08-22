defmodule TradingSystem.Markets do
  
  # stocks
  alias TradingSystem.Markets.StocksContext

  defdelegate create_stock(attrs), to: StocksContext, as: :create
  defdelegate get_stock(params), to: StocksContext, as: :get
  defdelegate get_stock!(params), to: StocksContext, as: :get!
  defdelegate paginate_stocks(market, params), to: StocksContext, as: :paginate
  
  # stock state
  alias TradingSystem.Markets.StockStateContext

  defdelegate create_state(attrs), to: StockStateContext, as: :create

  # stock blacklist
  alias TradingSystem.Markets.StockBlacklistContext

  defdelegate blacklist_stock?(symbol, user_id), to: StockBlacklistContext, as: :include?

  # stock star
  alias TradingSystem.Markets.StockStarContext

  defdelegate star_stock?(symbol, user_id), to: StockStarContext, as: :include?
end