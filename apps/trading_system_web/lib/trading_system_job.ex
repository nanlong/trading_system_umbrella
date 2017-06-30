defmodule TradingSystem.Job do
  use GenServer
  alias TradingSystem.Job.Worker.USStock5MinK

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{}, name: :job)
    start_tasks()
    {:ok, pid}
  end

  def start_tasks do
    USStock5MinK.start("FB")
  end

end