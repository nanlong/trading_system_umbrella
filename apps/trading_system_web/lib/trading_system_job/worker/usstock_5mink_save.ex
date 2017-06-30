defmodule TradingSystem.Job.Worker.USStock5MinKSave do
  alias TradingSystem.Stocks

  def perform(attrs) do
    with false <- Stocks.get_usstock_5mink?(to_keyword(attrs)) do
      Stocks.create_usstock_5mink(attrs)
    end

    {:ok, "save"}
  end

  def to_keyword(map) do
    Enum.map(map, fn({key, value}) -> {String.to_atom(key), value} end)
  end
end