defmodule TradingTask.Worker.CNStock do
  # Exq.enqueue(Exq, "default", TradingTask.Worker.CNStock, [])

  def perform() do
    Exq.enqueue(Exq, "default", TradingTask.Worker.CNStock.Stock, [1])
  end
end