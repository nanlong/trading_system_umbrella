defmodule TradingSystem.Graphql.StockResolver do
  alias TradingSystem.Stocks

  def all(_args, _info) do
    {:ok, Stocks.list_stock()}
  end

  def get(%{symbol: symbol}, _info) do
    {:ok, Stocks.get_stock!(symbol)}
  end

  def realtime(%{stocks: stocks}, _info) do
    stocks = stocks |> String.split(",") |> Enum.map(&(String.trim(&1) |> String.replace(".", "$")))
    {:ok, TradingApi.get("realtime", stocks: stocks)}
  end
end