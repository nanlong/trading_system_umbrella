alias TradingSystem.Stocks
alias TradingApi
require Logger


defmodule USStockList do
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
    {:ok, _} = Stocks.create_usstock(attrs)
    create_all(rest)
  end
end


defmodule USStockDailyK do

  def save do 
    symbols = Stocks.list_usstocks()
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
      case Stocks.get_last_usstock_dailyk(stock.symbol) do
        nil -> data
        last -> Enum.filter(data, &compare_dailyk?(&1, last))
      end
    
    create_all(data)

    save(rest, current + 1, total)
  end

  defp create_all([]), do: nil
  defp create_all([attrs | rest]) do
    {:ok, _} = Stocks.create_usstock_dailyk(attrs)
    create_all(rest)
  end

  defp compare_dailyk?(%{date: d1}, %{date: d2}) do
    case d1 |> Date.from_iso8601! |> Date.compare(d2) do
      :gt -> true
      _ -> false
    end
  end
end


defmodule USStockMinK do
  @types [5]
  
  def save do
    stocks = Stocks.list_usstocks()
    args = for stock <- stocks, type <- @types, do: {stock, type}
    total = length(args)
    Logger.info "加载美股5分钟K数据，合计： #{length(stocks)} 个股票"
    save(args, 1, total)
  end
  defp save([], _current, _total), do: nil
  defp save([{stock, type} | rest], current, total) do
    ProgressBar.render(current, total)

    data = 
      TradingApi.get("min_k", symbol: stock.symbol, type: type)
      |> Enum.map(&Map.put_new(&1, :symbol, stock.symbol))

    data =
      case Stocks.get_last_usstock_5mink(stock.symbol) do
        nil -> data
        stock_5mink -> Enum.filter(data, &compare_5mink?(&1, stock_5mink))
      end

    create_all(data, type)

    save(rest, current + 1, total)
  end

  defp create_all([], _type), do: nil
  defp create_all([attrs | rest], type) do
    case type do
      5 -> {:ok, _} = Stocks.create_usstock_5mink(attrs)
      true -> nil
    end

    create_all(rest, type)
  end

  defp compare_5mink?(%{datetime: d1}, %{datetime: d2}) do
    case d1 |> NaiveDateTime.from_iso8601! |> NaiveDateTime.compare(d2) do
      :gt -> true
      _ -> false
    end
  end
end


USStockList.save()
USStockDailyK.save()
USStockMinK.save()
