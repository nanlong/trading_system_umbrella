alias TradingSystem.Repo
alias TradingSystem.Markets
alias TradingSystem.Markets.Stocks
alias TradingSystem.Markets.StockDayk
import Ecto.Query, warn: false


Repo.all(Stocks)
|> Enum.map(fn(stock) -> 

  dayk =
    StockDayk
    |> where([dayk], dayk.symbol == ^stock.symbol)
    |> order_by([dayk], desc: dayk.date)
    |> limit(1)
    |> Repo.one()

  case dayk do
    nil -> nil
    dayk -> 
      IO.puts "更新股票 #{stock.symbol} #{stock.cname}"
      Markets.update_stock(stock, %{stock_dayk_id: dayk.id})
  end
end)