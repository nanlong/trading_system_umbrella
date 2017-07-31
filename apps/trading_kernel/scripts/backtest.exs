alias TradingSystem.Stocks
require Logger

Logger.info "开始回测"

stocks = Stocks.list_stock_state(date: ~D[2017-07-27])

Logger.info "#{length(stocks)} 个符合条件的股票"

results =
  Enum.map(stocks, fn state -> 
    TradingKernel.Backtest.run(state.symbol)
  end)

IO.inspect Enum.sort(results, &(&1.profit < &2.profit)), limit: 100

Logger.info "最小盈利: #{inspect(Enum.min_by(results, fn x -> x.profit end))}"
Logger.info "最大盈利: #{inspect(Enum.max_by(results, fn x -> x.profit end))}"

Logger.info "回测结束"

