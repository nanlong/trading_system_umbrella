defmodule TradingSystem.Graphql.StockBacktestResolver do
  
  def all(%{symbol: symbol}, %{context: %{current_user: current_user}}) do
    results = TradingKernel.Backtest.run(symbol, current_user)
    {:ok, results}
  end
end