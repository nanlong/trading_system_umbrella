defmodule TradingTask.Worker.CNStock do
  # TradingTask.Worker.CNStock.run()

  def run() do  
    Exq.enqueue(Exq, "default", TradingTask.Worker.CNStock.Stock, [1])
  end
end