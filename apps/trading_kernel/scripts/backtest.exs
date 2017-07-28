alias TradingSystem.Stocks

Enum.map(Stocks.list_stock_state(date: ~D[2017-07-27]), fn state -> 
  TradingKernel.Backtest.run(state.symbol)
end)
