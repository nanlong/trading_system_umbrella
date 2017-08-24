defmodule TradingTask.HKStock do
  alias TradingApi, as: Api

  @moduledoc """
  交易时间 周一至五9:30-12:00 PM1:00-4:00
  """
  alias TradingSystem.Markets

  def run() do
    load_list()
    load_dayk()
    generate_state()
    load_lot_size()
  end

  defp load_list(), do: load_list(page: 1)
  defp load_list(page: page) do
    %{body: body} = Api.get(:hk, "list", page: page)
    
    data = if is_nil(body), do: [], else: body
    
    Enum.map(data, fn(x) -> 
      attrs = %{
        symbol: Map.get(x, "symbol"),
        name: Map.get(x, "engname"),
        cname: Map.get(x, "name"),
        market: "HK",
        open: Map.get(x, "open"),
        highest: Map.get(x, "high"),
        lowest: Map.get(x, "low"),
        pre_close: Map.get(x, "prevclose"),
        diff: Map.get(x, "pricechange"),
        chg: Map.get(x, "changepercent"),
        amplitude: "0",
        volume: Map.get(x, "volume"),
        # category: "",
        # market_cap: "",
        # pe: ""
      }
      
      IO.puts "hk 保存股票数据 #{attrs.symbol}"

      case Markets.get_stock(symbol: attrs.symbol) do
        nil -> {:ok, _} = Markets.create_stock(attrs)
        stock -> {:ok, _} = Markets.update_stock(stock, attrs)
      end
    end)
    
    if not is_nil(body) do
      load_list(page: page + 1)
    end
  end

  defp load_dayk() do
    stock_list = Markets.list_stocks(:hk)
    load_dayk(stock_list)
  end

  defp load_dayk([]), do: nil
  defp load_dayk([stock | rest]) do
    IO.puts "hk 保存日K数据 #{stock.symbol}"

    dayk_list = 
      Api.get(:hk, "dayk", symbol: stock.symbol)
      |> Map.get(:body)
    
    dayk_list = (if is_nil(dayk_list), do: [], else: dayk_list)

    data = 
      dayk_list
      |> Enum.with_index()
      |> Enum.map(fn({x, index}) -> 
        pre_close =
          if index > 0 do
            dayk_list |> Enum.at(index - 1) |> Map.get("close")
          else
            x |> Map.get("close")
          end
        
        {:ok, datetime, _} =
          x
          |> Map.get("date")
          |> DateTime.from_iso8601()
        
        date = DateTime.to_date(datetime)

        %{
          date: date,
          symbol: stock.symbol,
          open: Map.get(x, "open"),
          highest: Map.get(x, "high"),
          lowest: Map.get(x, "low"),
          close: Map.get(x, "close"),
          pre_close: pre_close,
          volume: Map.get(x, "volume")
        }
      end)
      
    data =
      case Markets.list_stock_dayk(symbol: stock.symbol) |> List.last() do
        nil -> data
        dayk_last -> Enum.filter(data, &(Date.compare(&1.date, dayk_last.date) == :gt))
      end

    save_dayk(data)
    load_dayk(rest)
  end

  defp save_dayk([]), do: nil
  defp save_dayk([attrs | rest]) do
    IO.puts "hk 保存日K数据 #{attrs.symbol} #{attrs.date}"
    {:ok, _} = Markets.create_stock_dayk(attrs)
    save_dayk(rest)
  end

  defp generate_state do
    stock_list = Markets.list_stocks(:hk)
    generate_state(stock_list)
  end

  defp generate_state([]), do: nil
  defp generate_state([stock | rest]) do
    IO.puts "hk 保存state数据 #{stock.symbol}"

    dayk_data = Markets.list_stock_dayk(symbol: stock.symbol)

    data = case Markets.list_stock_state(symbol: stock.symbol) |> List.last() do
      nil -> dayk_data
      state_last -> Enum.filter(dayk_data, &(Date.compare(&1.date, state_last.date) == :gt))
    end

    save_state(data, dayk_data)
    generate_state(rest)
  end

  defp save_state([], _all_dayk), do: nil
  defp save_state([dayk | rest], all_dayk) do
    IO.puts "hk 保存state数据 #{dayk.symbol} #{dayk.date}"

    history = list_stock_dayk_before(all_dayk, date: dayk.date, limit: 300)
    dc_history = if length(history) == 1, do: history, else: Enum.slice(history, 0..-2)
    
    dc10 = TradingKernel.dc(dc_history, 10)
    dc20 = TradingKernel.dc(dc_history, 20)
    dc60 = TradingKernel.dc(dc_history, 60)

    attrs = %{
      date: dayk.date,
      symbol: dayk.symbol,
      tr: TradingKernel.tr(dayk),
      atr20: TradingKernel.atr(dayk),
      ma5: TradingKernel.ma(history, 5),
      ma10: TradingKernel.ma(history, 10),
      ma20: TradingKernel.ma(history, 20),
      ma30: TradingKernel.ma(history, 30),
      ma50: TradingKernel.ma(history, 50),
      ma60: TradingKernel.ma(history, 60),
      ma120: TradingKernel.ma(history, 120),
      ma150: TradingKernel.ma(history, 150),
      ma240: TradingKernel.ma(history, 240),
      ma300: TradingKernel.ma(history, 300),
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

    {:ok, _} = Markets.create_stock_state(attrs)

    save_state(rest, all_dayk)
  end

  defp list_stock_dayk_before(data, date: date, limit: limit) do
    data = Enum.reverse(data)
    cur_index = Enum.find_index(data, &(Date.compare(&1.date, date) == :eq))
    
    data
    |> Enum.slice(cur_index..cur_index + limit)
    |> Enum.reverse()
  end

  defp load_lot_size() do
    stock_list = Markets.list_stocks(:hk)
    load_lot_size(stock_list)
  end
  defp load_lot_size([]), do: nil
  defp load_lot_size([stock | rest]) do
    IO.puts "hk 更新股票每手股数 #{stock.symbol}"
    %{body: attrs} = Api.get(:hk, "lotSize", symbol: stock.symbol)
    {:ok, _} = Markets.update_stock(stock, attrs)
    load_lot_size(rest)
  end
end