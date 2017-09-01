defmodule TradingSystem.Markets do
  
  # stocks
  alias TradingSystem.Markets.StocksContext

  defdelegate create_stock(attrs), to: StocksContext, as: :create
  defdelegate update_stock(stock, attrs), to: StocksContext, as: :update
  defdelegate get_stock(params), to: StocksContext, as: :get
  defdelegate get_stock!(params), to: StocksContext, as: :get!
  defdelegate paginate_stocks(market, params), to: StocksContext, as: :paginate
  defdelegate list_stocks(market), to: StocksContext, as: :list

  # stock dayk
  alias TradingSystem.Markets.StockDaykContext

  defdelegate create_stock_dayk(attrs), to: StockDaykContext, as: :create
  defdelegate get_stock_dayk(params), to: StockDaykContext, as: :get
  defdelegate list_stock_dayk(params), to: StockDaykContext, as: :list

  # stock state
  alias TradingSystem.Markets.StockStateContext

  defdelegate create_stock_state(attrs), to: StockStateContext, as: :create
  defdelegate list_stock_state(params), to: StockStateContext, as: :list

  # stock blacklist
  alias TradingSystem.Markets.StockBlacklistContext

  defdelegate create_stock_blacklist(attrs), to: StockBlacklistContext, as: :create
  defdelegate delete_stock_blacklist(symbol, user_id), to: StockBlacklistContext, as: :delete
  defdelegate blacklist_stock?(symbol, user_id), to: StockBlacklistContext, as: :include?


  # stock star
  alias TradingSystem.Markets.StockStarContext

  defdelegate create_stock_star(attrs), to: StockStarContext, as: :create
  defdelegate delete_stock_star(symbol, user_id), to: StockStarContext, as: :delete
  defdelegate star_stock?(symbol, user_id), to: StockStarContext, as: :include?

  # futures
  alias TradingSystem.Markets.FuturesContext

  defdelegate create_future(attrs), to: FuturesContext, as: :create
  defdelegate update_future(future, attrs), to: FuturesContext, as: :update
end