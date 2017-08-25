defmodule TradingTask.Worker.USStock do
  # TradingTask.Worker.USStock.run()

  def run() do
    Exq.enqueue(Exq, "default", TradingTask.Worker.USStock.Stock, [1])
  end
end