alias TradingSystem.Stocks
alias TradingApi.LiangYee.USStock, as: USSTockApi
alias TradingApi.Sina.USStock, as: SinaUSStock
alias Decimal, as: D
require Logger

NimbleCSV.define(CSVParser, separator: ",", escape: "\"")


defmodule USStockList do
  @files ["AMEX.csv", "NASDAQ.csv", "NYSE.csv"]

  def save do
    data = data() 
    # IO.inspect data
    total = length(data)
    IO.puts "加载美股列表数据，合计： #{total} 个股票"
    if total != Stocks.count_usstocks() do
      save(data, 1, total)
    else
      ProgressBar.render(100, 100)
    end
  end
  defp save([], _current, _total), do: nil
  defp save([attrs | rest], current, total) do
    try do
      attrs.symbol
      |> Stocks.get_usstock!()
      |> Stocks.update_usstock(attrs)
    rescue
      _ in Ecto.NoResultsError ->
        {:ok, _} = Stocks.create_usstock(attrs)
    end

    ProgressBar.render(current, total)
    save(rest, current + 1, total)
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
    |> Enum.to_list
  end

  defp read([], data), do: data
  defp read([file_name | rest], data) do
    file_data =
      "apps/trading_system/priv/repo/files/" <> file_name
      |> Path.absname
      |> File.stream!
      |> CSVParser.parse_stream
      |> Stream.map(fn [symbol, name, lastSale, marketCap | _] ->
        %{
          symbol: String.strip(symbol), 
          name: String.strip(name),
          last_sale: to_decimal(lastSale),
          market_cap: market_cap(marketCap)
        }
      end)

      read(rest, data ++ [file_data])
  end

  defp to_decimal("n/a"), do: D.new(0)
  defp to_decimal(value), do: D.new(value)

  # 计算市值
  defp market_cap("n/a"), do: D.new(0)
  defp market_cap("$" <> value), do: market_cap(String.split_at(value, -1))
  defp market_cap({value, "M"}), do: D.mult(D.new(value), D.new(1_000_000))
  defp market_cap({value, "B"}), do: D.mult(D.new(value), D.new(1_000_000_000))
  defp market_cap(_), do: D.new(0)
end


defmodule USStockDailyK do
  @start_date "1900-01-01"
  @end_date Date.utc_today |> Date.to_string

  def save do 
    symbols = 
      Stocks.list_usstocks()
      |> Enum.map(&(&1.symbol))

    total = length(symbols)
    IO.puts "加载美股日K数据，合计： #{total} 个股票"
    save(symbols, 1, total)
  end
  defp save([], _current, _total), do: nil
  defp save([symbol | rest], current, total) do
    ProgressBar.render(current, total)
    IO.puts " >> #{symbol}"
    data = get_data(symbol)
    save_data(symbol, data)
    
    :timer.sleep(1000)
    save(rest, current + 1, total)
  end

  def get_data(symbol), do: get_data(symbol, 0, 9)
  def get_data(symbol, retry_num, retry_max) when retry_num > retry_max do
    Logger.info "操作超时，股票代码：#{symbol}"
    []
  end
  def get_data(symbol, retry_num, retry_max) do
    case SinaUSStock.get("daily_k", symbol: symbol) do
      %{body: body} -> body
      %{message: "req_timedout"} -> 
        :timer.sleep(1000)
        get_data(symbol, retry_num + 1, retry_max)
      _ -> []
    end
  end

  defp save_data(symbol, data) do
    Enum.map(data, &save_item(symbol, &1))
  end

  defp save_item(symbol, attrs) do
    attrs = attrs |> Map.put_new("symbol", symbol)
    unless Stocks.get_us_stock_daily_prices(symbol: symbol, date: Map.get(attrs, "date")) do
      attrs = Map.put_new(attrs, "pre_close_price", Stocks.get_pre_close_price(symbol, Map.get(attrs, "date")))
      {:ok, _} = Stocks.create_us_stock_daily_prices(attrs)
    end
  end
end


defmodule USStockMinK do
  @types [5]
  
  def save do
    stocks = Stocks.list_usstocks()
    args = for stock <- stocks, type <- @types, do: {stock, type}
    total = length(args)
    IO.puts "加载美股5分钟K数据，合计： #{length(stocks)} 个股票 | #{total} 个请求"
    save(args, 1, total)
  end
  defp save([], _current, _total), do: nil
  defp save([{stock, type} | rest], current, total) do
    data = 
      get_data(stock.symbol, type)
      |> Enum.map(&Map.put_new(&1, "symbol", stock.symbol))

    data =
      case Stocks.get_last_usstock_5mink(stock.symbol) do
        nil -> data
        stock_5mink -> Enum.filter(data, &(compare_5mink?(&1, stock_5mink)))
      end

    save_data(data, type)
    ProgressBar.render(current, total)
    :timer.sleep(1000)
    save(rest, current + 1, total)
  end

  defp compare_5mink?(%{"datetime" => d1}, %{datetime: d2}) do
    d1 =
      d1
      |> NaiveDateTime.from_iso8601!
      |> NaiveDateTime.to_erl
      |> :calendar.datetime_to_gregorian_seconds
    
    d2 =
      d2
      |> NaiveDateTime.to_erl
      |> :calendar.datetime_to_gregorian_seconds
    
    d1 > d2
  end

  def get_data(symbol, type), do: get_data(symbol, type, 0, 9)
  def get_data(symbol, _type, retry_num, retry_max) when retry_num > retry_max do
    Logger.info "操作超时，股票代码：#{symbol}"
    []
  end
  def get_data(symbol, type, retry_num, retry_max) do
    case SinaUSStock.get("min_k", symbol: symbol, type: type) do
      %{body: body} -> body
      %{message: "req_timedout"} -> 
        :timer.sleep(1000)
        get_data(symbol, type, retry_num + 1, retry_max)
      _ -> []
    end
  end

  def save_data([], _type), do: nil
  def save_data([attrs | rest], type) do
    case type do
      5 -> {:ok, _} = Stocks.create_usstock_5mink(attrs)
      true -> nil
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
