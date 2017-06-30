defmodule TradingSystem.Job.Worker.USStock5MinK do
  @moduledoc """
  日K 更新
  """
  require Logger
  alias TradingSystem.Job.Worker.USStock5MinK
  alias TradingSystem.Job.Worker.USStock5MinKSave
  alias TradingApi.Sina.USStock, as: SinaUSStock

  def perform(symbol) do
    SinaUSStock.get("getMinK", symbol: symbol, type: 5).body
    |> Enum.map(&Map.put_new(&1, "symbol", symbol))
    |> Enum.map(&Exq.enqueue(Exq, "default", USStock5MinKSave, [&1]))  
  end

  def start(symbol), do: Exq.enqueue(Exq, "default", USStock5MinK, [symbol])
end