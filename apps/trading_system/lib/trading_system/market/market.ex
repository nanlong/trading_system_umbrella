defmodule TradingSystem.Market do
  
  alias TradingSystem.Market.Context.Stocks

  defdelegate list_stocks, to: Stocks, as: :list
end