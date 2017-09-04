defmodule TradingTask.Worker.GFuture do
  # TradingTask.Worker.GFuture.run()

  def run() do  
    Exq.enqueue(Exq, "default", TradingTask.Worker.GFuture.List, [])
  end
end