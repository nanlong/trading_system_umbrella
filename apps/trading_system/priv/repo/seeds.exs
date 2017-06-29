alias TradingSystem.Stocks
alias TradingApi.LiangYee.USStock, as: USSTockApi
alias TradingApi.Sina.USStock, as: SinaUSStock

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


defmodule USStockMinK do
  @types [5]
  
  def save do
    stocks =  Stocks.list_usstocks()
    args = for stock <- stocks, type <- @types, do: {stock, type}
    save(args)
  end
  defp save([]), do: nil
  defp save([{stock, type} | rest]) do
    data = 
      get_data(stock.symbol, type)
      |> Enum.map(&Map.put_new(&1, "symbol", stock.symbol))

    save_data(data, type)
    save(rest)
  end

  def get_data(symbol, type), do: get_data(symbol, type, 0, 9)
  def get_data(_symbol, _type, retry_num, retry_max) when retry_num > retry_max, do: []
  def get_data(symbol, type, retry_num, retry_max) do
    case SinaUSStock.get("getMinK", symbol: symbol, type: type) do
      %{body: body} -> body
      %{message: "req_timedout"} -> get_data(symbol, type, retry_num + 1, retry_max)
      _ -> []
    end
  end

  def save_data([], _type), do: nil
  def save_data([attrs | rest], type) do
    with false <- Stocks.get_usstock_5mink?(to_keyword(attrs)) do
      case type do
        5 -> Stocks.create_usstock_5mink(attrs)
        true -> nil
      end
    end
    
    save_data(rest, type)
  end

  def to_keyword(map) do
    Enum.map(map, fn({key, value}) -> {String.to_atom(key), value} end)
  end
end


USStockList.save()
USStockDailyK.save()
USStockMinK.save()
