alias TradingSystem.Stocks
alias TradingSystem.Markets
alias TradingApi
require Logger


defmodule Stock do
  @per_page 20

  def save do
    %{count: count} = TradingApi.get("list", page: 1)
    Logger.info "加载美股列表数据，合计： #{count} 个股票"
    ProgressBar.render(0, count)
    save(1, count)
  end
  defp save(page, count) when (page - 1) * @per_page <= count do
    %{data: data} = TradingApi.get("list", page: page)
    create_all(data)
    ProgressBar.render((page - 1) * @per_page + length(data), count)
    save(page + 1, count)
  end
  defp save(_page, _count), do: nil

  defp create_all([]), do: nil
  defp create_all([attrs | rest]) do
    {:ok, _} = Stocks.create_stock(attrs)
    create_all(rest)
  end
end


defmodule StockDailyK do

  def save do 
    symbols = Stocks.list_stock()
    total = length(symbols)
    Logger.info "加载美股日K数据，合计： #{total} 个股票"
    save(symbols, 1, total)
  end
  defp save([], _current, _total), do: nil
  defp save([stock | rest], current, total) do
    ProgressBar.render(current, total)

    data =
      TradingApi.get("daily_k", symbol: stock.symbol)
      |> Enum.map(&Map.put_new(&1, :symbol, stock.symbol))

    data =
      case Stocks.get_last_stock_dailyk(stock.symbol) do
        nil -> data
        last -> Enum.filter(data, &compare_date?(&1, last))
      end
    
    create_all(data)

    save(rest, current + 1, total)
  end

  defp create_all([]), do: nil
  defp create_all([attrs | rest]) do
    {:ok, _} = Stocks.create_stock_dailyk(attrs)
    create_all(rest)
  end

  defp compare_date?(%{date: d1}, %{date: d2}) do
    case d1 |> Date.from_iso8601! |> Date.compare(d2) do
      :gt -> true
      _ -> false
    end
  end
end


# defmodule StockMinK do
#   @types [5]
  
#   def save do
#     stocks = Stocks.list_stock()
#     args = for stock <- stocks, type <- @types, do: {stock, type}
#     total = length(args)
#     Logger.info "加载美股5分钟K数据，合计： #{length(stocks)} 个股票"
#     save(args, 1, total)
#   end
#   defp save([], _current, _total), do: nil
#   defp save([{stock, type} | rest], current, total) do
#     ProgressBar.render(current, total)
#     data = 
#       TradingApi.get("min_k", symbol: stock.symbol, type: type)
#       |> Enum.map(&Map.put_new(&1, :symbol, stock.symbol))

#     data =
#       case Stocks.get_last_stock_5mink(stock.symbol) do
#         nil -> data
#         stock_5mink -> Enum.filter(data, &compare_datetime?(&1, stock_5mink))
#       end

#     create_all(data, type)

#     save(rest, current + 1, total)
#   end

#   defp create_all([], _type), do: nil
#   defp create_all([attrs | rest], type) do
#     case type do
#       5 -> {:ok, _} = Stocks.create_stock_5mink(attrs)
#       true -> nil
#     end

#     create_all(rest, type)
#   end

#   defp compare_datetime?(%{datetime: d1}, %{datetime: d2}) do
#     case d1 |> NaiveDateTime.from_iso8601! |> NaiveDateTime.compare(d2) do
#       :gt -> true
#       _ -> false
#     end
#   end
# end


defmodule StockState do
  
  def save do
    stocks = Stocks.list_stock()
    # stocks = [Stocks.get_stock!("BABA")]
    Logger.info "统计美股股票信息，合计： #{length(stocks)} 个股票"
    save(stocks, 1, length(stocks))
  end

  def save([], _current, _total), do: nil
  def save([stock | rest], current, total) do
    ProgressBar.render(current, total)
    IO.inspect stock.symbol
    dailyk = Stocks.list_stock_dailyk(stock.symbol)
    dailyk =
      case Stocks.get_last_stock_state(stock.symbol) do
        nil -> dailyk
        last -> Enum.filter(dailyk, &compare_date?(&1, last))
      end
    create_all(dailyk)
    save(rest, current + 1, total)
  end

  def create_all([]), do: nil
  def create_all([k | rest]) do
    create_item(k, Stocks.get_stock_state?(k))
    create_all(rest)
  end

  def create_item(_dailyk, true), do: nil
  def create_item(%{symbol: symbol, date: date} = dailyk, false) do
    history = Stocks.history_stock_dailyk(dailyk, 300)

    history_today =
      if length(history) == 1 and Enum.at(history, 0) == dailyk do
        history
      else 
        history ++ [dailyk]
      end

    dc10 = TradingKernel.dc(history, 10)
    dc20 = TradingKernel.dc(history, 20)
    dc60 = TradingKernel.dc(history, 60)

    attrs = %{
      date: date,
      symbol: symbol,
      tr: TradingKernel.tr(dailyk),
      atr20: TradingKernel.atr(dailyk),
      ma5: TradingKernel.ma(history_today, 5),
      ma10: TradingKernel.ma(history_today, 10),
      ma20: TradingKernel.ma(history_today, 20),
      ma30: TradingKernel.ma(history_today, 30),
      ma50: TradingKernel.ma(history_today, 50),
      ma60: TradingKernel.ma(history_today, 60),
      ma120: TradingKernel.ma(history_today, 120),
      ma150: TradingKernel.ma(history_today, 150),
      ma240: TradingKernel.ma(history_today, 240),
      ma300: TradingKernel.ma(history_today, 300),
      dcu10: dc10.up,
      dca10: dc10.avg,
      dcl10: dc10.lower,
      dcu20: dc20.up,
      dca20: dc20.avg,
      dcl20: dc20.lower,
      dcu60: dc60.up,
      dca60: dc60.avg,
      dcl60: dc60.lower,
    }

    {:ok, _} = Markets.create_state(attrs)
  end

  defp compare_date?(%{date: d1}, %{date: d2}) do
    case Date.compare(d1, d2) do
      :gt -> true
      _ -> false
    end
  end
end

Stock.save()
StockDailyK.save()
# StockMinK.save()
StockState.save()