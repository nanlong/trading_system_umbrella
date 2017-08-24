defmodule TradingTask.Worker.CNStock do

  def perform() do
    Exq.enqueue(Exq, "default", TradingTask.Worker.CNStock.Stock, [1])
  end
end