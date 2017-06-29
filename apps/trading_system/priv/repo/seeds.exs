# alias TradingApi.LiangYee.USStock, as: USSTockApi
# alias TradingSystem.Stocks

# us_symbols = ["TSLA", "FB", "BABA", "GOOG", "MSFT", "AAPL", "NVDA", "BRK.B"]

# defmodule Api do
#   @start_date "2010-01-01"
#   @end_date Date.utc_today |> Date.to_string

#   def get(symbol) do
#     get_data(symbol, @start_date)
#   end

#   def get_data(symbol, date) do
#     resp = USSTockApi.get("/getDailyKBar", symbol: symbol, startDate: date, endDate: @end_date).body
    
#     case resp do
#       [] ->
#         :timer.sleep(1000)
#         get_data(symbol, add_years(date))
#       data -> data
#     end
#   end

#   defp add_years(date, years \\ 1) do
#     {year, month, day} = Date.from_iso8601!(date) |> Date.to_erl
#     Date.from_erl!({year + years, month, day}) |> Date.to_string
#   end
# end


# Enum.map(us_symbols, fn symbol -> 
#   resp = Api.get(symbol)

#   # data =
#   Enum.map(resp, fn attrs -> 
#     attrs = Map.put_new(attrs, :symbol, symbol)
#     unless Stocks.get_us_stock_daily_prices(attrs) do
#       Stocks.create_us_stock_daily_prices(attrs)
#     end
#   end)

#   # IO.inspect(data, limit: 100)
#   :timer.sleep(1000)
# end)
alias TradingSystem.Stocks

NimbleCSV.define(CSVParser, separator: ",", escape: "\"")

defmodule USStockList do
  @files ["AMEX_358.csv", "NASDAQ_3209.csv", "NYSE_3147.csv"]

  def data do
    read(@files, [])
    |> Stream.concat
    |> Stream.filter(fn(x) -> not String.contains?(x.symbol, "^") end)
  end

  def count(data), do: count(Enum.to_list(data), [])
  def count([], cache), do: Enum.filter(cache, fn({_, value}) -> value > 1 end)
  def count([item | rest], cache) do
    cache = Keyword.update(cache, String.to_atom(item.symbol), 1, &(&1 + 1))
    count(rest, cache)
  end

  def save do
    if length(Enum.to_list(data())) != Stocks.count_usstocks() do
      Enum.map(data(), fn(attrs) -> 
        try do
          Stocks.get_usstock!(attrs)
        rescue
          _ in Ecto.NoResultsError ->
            Stocks.create_usstock(attrs)
        end
      end)
    end
  end

  defp read([], data), do: data
  defp read([file_name | rest], data) do
    file_data =
      "apps/trading_system/priv/repo/files/" <> file_name
      |> Path.absname
      |> File.stream!
      |> CSVParser.parse_stream
      |> Stream.map(fn [symbol, name | _] ->
        %{symbol: String.strip(symbol), name: String.strip(name)}
      end)

      read(rest, data ++ [file_data])
  end
end


USStockList.save()

