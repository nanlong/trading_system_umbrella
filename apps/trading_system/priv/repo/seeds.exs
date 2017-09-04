alias TradingSystem.Markets
alias TradingApi.Sina.GFuture, as: Api


Markets.list_future(:g)
|> Enum.map(fn(x) -> 
  %{body: body} = Api.get("lotSize", symbol: x.symbol, timeout: 30_000)

  [
    x.symbol, 
    x.name, 
    Map.get(body, "trading_unit"), 
    Map.get(body, "price_quote"), 
    Map.get(body, "minimum_price_change"), 
    Map.get(body, "trading_hours")
  ]
end)
|> Enum.map(fn(x) -> IO.puts(x |> Enum.join(" ") ) end)