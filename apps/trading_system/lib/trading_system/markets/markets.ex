defmodule TradingSystem.Markets do
  
  # stocks
  alias TradingSystem.Markets.StocksContext

  defdelegate create_stock(attrs), to: StocksContext, as: :create
  defdelegate get_stock(params), to: StocksContext, as: :get
  defdelegate paginate_stocks(market, params), to: StocksContext, as: :paginate
  
  # stock_state
  alias TradingSystem.Markets.StockStateContext

  defdelegate create_state(attrs), to: StockStateContext, as: :create
end