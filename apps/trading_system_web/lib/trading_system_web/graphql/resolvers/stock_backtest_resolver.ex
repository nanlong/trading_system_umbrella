defmodule TradingSystem.Graphql.StockBacktestResolver do
  
  def all(%{symbol: symbol}, _info) do
    results = TradingKernel.Backtest.run(symbol).history |> Tuple.to_list()
    {:ok, results}
  end
end