defmodule TradingSystem.Graphql.StockDetailResolver do
  alias TradingApi.Sina.CNStock
  alias TradingApi.Sina.HKStock


  def get_cn(%{symbol: symbol}, _info) do
    %{body: body} = CNStock.get("detail", symbol: symbol)
    
    {:ok, to_data(body)}
  end

  def get_hk(%{symbol: symbol}, _info) do
    %{body: body} = HKStock.get("detail", symbol: symbol)
    {:ok, to_data(body)}
  end
  
  def to_data(data) do
    for {key, val} <- data, into: %{}, do: {String.to_atom(key), val}
  end
end