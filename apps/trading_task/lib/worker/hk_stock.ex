defmodule TradingTask.Worker.HKStock do
  # Exq.enqueue(Exq, "default", TradingTask.Worker.HKStock, [])

  def perform() do
    Exq.enqueue(Exq, "default", TradingTask.Worker.HKStock.Stock, [1])
  end
end