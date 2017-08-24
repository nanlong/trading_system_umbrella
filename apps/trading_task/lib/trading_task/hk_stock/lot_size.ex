defmodule TradingTask.HKStock.LotSize do
  alias TradingApi, as: Api

  @moduledoc """
  交易时间 周一至五9:30-12:00 PM1:00-4:00
  """
  alias TradingSystem.Markets

  def run() do
    load_lot_size()
  end

  defp load_lot_size() do
    stock_list = Markets.list_stocks(:hk)
    load_lot_size(stock_list)
  end
  defp load_lot_size([]), do: nil
  defp load_lot_size([stock | rest]) do
    IO.puts "hk 更新股票每手股数 #{stock.symbol}"
    %{body: attrs} = Api.get(:hk, "lotSize", symbol: stock.symbol)
    {:ok, _} = Markets.update_stock(stock, attrs)
    load_lot_size(rest)
  end
end