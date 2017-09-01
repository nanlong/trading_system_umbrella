defmodule TradingTask.Worker.IFuture do
  # TradingTask.Worker.IFuture.run()

  def run() do  
    Exq.enqueue(Exq, "default", TradingTask.Worker.IFuture.List, [])
  end
end