defmodule TradingTask.USStock do
  alias TradingApi.Sina.USStock, as: Api

  @moduledoc """
  交易时间 周一至五9:30-12:00 PM1:00-4:00
  """
  alias TradingSystem.Markets

  def run() do
    load_list()
    load_dayk()
    generate_state()
  end

  defp load_list(), do: load_list(page: 1)
  defp load_list(page: page) do
    %{body: body} = Api.get("list", page: page)
    
    data = Map.get(body, :data)

    Enum.map(data, fn(attrs) ->       
      IO.puts "us 保存股票数据 #{attrs.symbol}"

      case Markets.get_stock(symbol: attrs.symbol) do
        nil -> Markets.create_stock(attrs)
        stock -> Markets.update_stock(stock, attrs)
      end
    end)
    
    if length(data) > 0 do
      load_list(page: page + 1)
    end
  end


  defp load_dayk() do
    stock_list = Markets.list_stocks(:us)
    load_dayk(stock_list)
  end

  defp load_dayk([]), do: nil
  defp load_dayk([stock | rest]) do
    IO.puts "us 保存日K数据 #{stock.symbol}"

    dayk_list = 
      Api.get("daily_k", symbol: stock.symbol)
      |> Map.get(:body)

    dayk_list = (if is_nil(dayk_list), do: [], else: dayk_list)

    data = 
      dayk_list
      |> Enum.with_index()
      |> Enum.map(fn({x, index}) -> 
        pre_close =
          if index > 0 do
            dayk_list |> Enum.at(index - 1) |> Map.get(:close)
          else
            x |> Map.get(:close)
          end
        
        Map.put(x, :pre_close, pre_close)
      end)
      
    data =
      case Markets.list_stock_dayk(symbol: stock.symbol) |> List.last() do
        nil -> data
        dayk_last -> Enum.filter(data, &(Date.compare(Date.from_iso8601!(&1.date), dayk_last.date) == :gt))
      end

    save_dayk(data)
    load_dayk(rest)
  end

  defp save_dayk([]), do: nil
  defp save_dayk([attrs | rest]) do
    IO.puts "us 保存日K数据 #{attrs.symbol} #{attrs.date}"
    Markets.create_stock_dayk(attrs)
    save_dayk(rest)
  end

  defp generate_state do
    stock_list = Markets.list_stocks(:us)
    generate_state(stock_list)
  end

  defp generate_state([]), do: nil
  defp generate_state([stock | rest]) do
    IO.puts "us 保存state数据 #{stock.symbol}"

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
    IO.puts "us 保存state数据 #{dayk.symbol} #{dayk.date}"

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

    Markets.create_stock_state(attrs)

    save_state(rest, all_dayk)
  end

  defp list_stock_dayk_before(data, date: date, limit: limit) do
    data = Enum.reverse(data)
    cur_index = Enum.find_index(data, &(Date.compare(&1.date, date) == :eq))
    
    data
    |> Enum.slice(cur_index..cur_index + limit)
    |> Enum.reverse()
  end
end