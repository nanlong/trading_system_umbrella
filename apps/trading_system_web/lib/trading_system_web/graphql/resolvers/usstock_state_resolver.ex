defmodule TradingSystem.Graphql.USStockStateResolver do
  alias TradingSystem.Stocks

  def all(_args, _info) do
    stocks = Stocks.list_usstock_state()
    prices = TradingApi.get("realtime", stocks: (for stock <- stocks, do: stock.symbol))

    data =
      stocks
      |> Enum.zip(prices)
      |> Enum.map(fn({stock, price}) -> 
        stock
        |> Map.put_new(:high_d20, Map.get(stock, :high_20))
        |> Map.put_new(:high_d60, Map.get(stock, :high_60))
        |> Map.put_new(:low_d10, Map.get(stock, :low_10))
        |> Map.put_new(:low_d20, Map.get(stock, :low_20))
        |> Map.put_new(:n_ratio_d20, Map.get(stock, :n_ratio_20))
        |> Map.put_new(:n_ratio_d60, Map.get(stock, :n_ratio_60))
        |> Map.put_new(:avg_d50_gt_d300, Map.get(stock, :avg_50_gt_300))
        |> Map.put_new(:price, price.price)
        |> Map.put_new(:random, Enum.random(1..99))
      end)
      
    {:ok, data}
  end
end