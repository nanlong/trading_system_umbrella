defmodule TradingTask.Worker.USStock do
  # Exq.enqueue(Exq, "default", TradingTask.Worker.USStock, [])

  def perform() do
    Exq.enqueue(Exq, "default", TradingTask.Worker.USStock.Stock, [1])
  end
end