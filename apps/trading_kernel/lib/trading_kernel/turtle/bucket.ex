defmodule TradingKernel.Turtle.State do
  defstruct [
    :symbol, 
    :today, 
    :account, 
    :history, 
    :min_history, 
    :status_50_300, 
    :donchian, 
    :breakout,
    :n,
    :unit,
    :trading?
  ]
end

defmodule TradingKernel.Turtle.Bucket do
  @moduledoc false

  use GenServer
  alias TradingKernel.Turtle.State

  @name :trutle_bucket
  @initial_value %State{}

  def start_link do
    GenServer.start_link(__MODULE__, @initial_value, name: @name)
  end

  def state do
    GenServer.call(@name, :state)
  end

  def get(key) do
    GenServer.call(@name, {:get, key})
  end

  def put(key, value) do
    GenServer.call(@name, {:put, key, value})
  end

  def has_key?(key) do
    GenServer.call(@name, {:has_key, key})
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  def handle_call({:put, key, value}, _from, state) do
    state = Map.put(state, key, value)
    {:reply, state, state}
  end

  def handle_call({:has_key, key}, _from, state) do
    {:reply, Map.has_key?(state, key), state}
  end
  
end