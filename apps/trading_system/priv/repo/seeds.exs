alias TradingSystem.Stocks
alias TradingApi.LiangYee.USStock, as: USSTockApi

NimbleCSV.define(CSVParser, separator: ",", escape: "\"")


defmodule USStockList do
  @files ["AMEX.csv", "NASDAQ.csv", "NYSE.csv"]

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

  def count(data), do: count(Enum.to_list(data), [])
  def count([], cache), do: Enum.filter(cache, fn({_, value}) -> value > 1 end)
  def count([item | rest], cache) do
    cache = Keyword.update(cache, String.to_atom(item.symbol), 1, &(&1 + 1))
    count(rest, cache)
  end

  defp data do
    read(@files, [])
    |> Stream.concat
    |> Stream.filter(fn(x) -> not String.contains?(x.symbol, "^") end)
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


defmodule USStockDailyK do
  @symbols ["TSLA", "FB", "BABA", "GOOG", "MSFT", "AAPL", "NVDA", "BRK.B"]
  @start_date "1900-01-01"
  @end_date Date.utc_today |> Date.to_string

  def save do
    Enum.map(@symbols, fn symbol -> \
      start_date = get_start_date(symbol)
      
      if start_date < @end_date do
        resp = get_data(symbol, start_date)
        save_data(symbol, resp)
        :timer.sleep(1000)
      end
    end)
  end

  defp get_data(symbol, start_date) do
    USSTockApi.get("/getDailyKBar", symbol: symbol, startDate: start_date, endDate: @end_date).body
  end

  defp get_start_date(symbol) do
    case Stocks.get_last_usstockdailyk(symbol) do
      nil -> @start_date
      usstock -> usstock.date |> Calendar.Date.next_day! |> Date.to_string
    end
  end

  defp save_data(symbol, data) do
    Enum.map(data, &save_item(symbol, &1))
  end

  defp save_item(symbol, attrs) do
    attrs = Map.put_new(attrs, :symbol, symbol)
    unless Stocks.get_us_stock_daily_prices(attrs) do
      attrs = Map.put_new(attrs, :pre_close_price, Stocks.get_pre_close_price(symbol, attrs.date))
      Stocks.create_us_stock_daily_prices(attrs)
    end
  end
end


USStockList.save()
USStockDailyK.save()

