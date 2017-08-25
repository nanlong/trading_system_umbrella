defmodule TradingTask.Worker.HKStock do
  # TradingTask.Worker.HKStock.run()

  def run() do
    Exq.enqueue(Exq, "default", TradingTask.Worker.HKStock.Stock, [1])
  end
end