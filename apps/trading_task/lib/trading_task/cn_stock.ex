defmodule TradingTask.CNStock do
  alias TradingApi.Sina.CNStock, as: Api

  @moduledoc """
  交易时间 周一至五9:30-11:30 PM1:00-3:00
  """
  alias TradingSystem.Markets

  def run() do
    load_list()
    load_dayk()
    generate_state()
  end

  def load_list(), do: load_list(page: 1)
  def load_list(page: page) do
    %{body: body} = Api.get("list", page: page)
    data = get_in(body, ["result", "data", "data"])

    Enum.map(data, fn(x) -> 
      attrs = %{
        symbol: Map.get(x, "symbol"),
        name: get_in(x, ["ext", "name"]),
        cname: get_in(x, ["ext", "name"]),
        market: Regex.named_captures(~r/(?<market>[sh|sz]+)/, Map.get(x, "symbol")) |> Map.get("market") |> String.upcase(),
        open: get_in(x, ["ext", "open"]),
        highest: get_in(x, ["ext", "high"]),
        lowest: get_in(x, ["ext", "low"]),
        pre_close: get_in(x, ["ext", "prevclose"]),
        diff: get_in(x, ["ext", "change"]),
        chg: get_in(x, ["ext", "percent"]),
        amplitude: get_in(x, ["ext", "amplitude"]) |> to_string(),
        volume: get_in(x, ["ext", "totalVolume"]),
        # category: "",
        # market_cap: "",
        # pe: ""
      }
      
      IO.puts "保存股票数据 #{attrs.symbol}"

      case Markets.get_stock(symbol: attrs.symbol) do
        nil -> Markets.create_stock(attrs)
        stock -> Markets.update_stock(stock, attrs)
      end
    end)
    
    page_cur = get_in(body, ["result", "data", "pageCur"])
    page_num = get_in(body, ["result", "data", "pageNum"])
    page_next = page_cur + 1
    
    if page_next <= page_num do
      load_list(page: page_next)
    end
  end


  def load_dayk() do
    stock_list = Markets.list_stocks(:cn)
    load_dayk(stock_list)
  end

  defp load_dayk([]), do: nil
  defp load_dayk([stock | rest]) do
    IO.puts "保存日K数据 #{stock.symbol}"

    dayk_list = 
      Api.get("dayk", symbol: stock.symbol)
      |> Map.get(:body)
    
    dayk_list = (if is_nil(dayk_list), do: [], else: dayk_list)
    
    dayk_last = 
      Markets.list_stock_dayk(symbol: stock.symbol) 
      |> List.last()

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

          %{
            date: Map.get(x, "day"),
            symbol: stock.symbol,
            open: Map.get(x, "open"),
            highest: Map.get(x, "high"),
            lowest: Map.get(x, "low"),
            close: Map.get(x, "close"),
            pre_close: pre_close,
            volume: Map.get(x, "volume")
          }
      end)
      |> Enum.filter(&(Date.compare(Date.from_iso8601!(&1.date), dayk_last.date) == :gt))

    save_dayk(data)
    load_dayk(rest)
  end

  defp save_dayk([]), do: nil
  defp save_dayk([attrs | rest]) do
    IO.puts "保存日K数据 #{attrs.symbol} #{attrs.date}"
    Markets.create_stock_dayk(attrs)
    save_dayk(rest)
  end

  def generate_state do
    stock_list = Markets.list_stocks(:cn)
    generate_state(stock_list)
  end

  defp generate_state([]), do: nil
  defp generate_state([stock | rest]) do
    IO.puts "保存state数据 #{stock.symbol}"

    dayk_data = Markets.list_stock_dayk(symbol: stock.symbol)
    state =  Markets.list_stock_state(symbol: stock.symbol) |> List.last()
    data = Enum.filter(dayk_data, &(Date.compare(&1.date, state.date) == :gt))

    save_state(data, dayk_data)
    generate_state(rest)
  end

  defp save_state([], _all_dayk), do: nil
  defp save_state([dayk | rest], all_dayk) do
    IO.puts "保存state数据 #{dayk.symbol} #{dayk.date}"

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

  def list_stock_dayk_before(data, date: date, limit: limit) do
    data = Enum.reverse(data)
    cur_index = Enum.find_index(data, &(Date.compare(&1.date, date) == :eq))
    
    data
    |> Enum.slice(cur_index..cur_index + limit)
    |> Enum.reverse()
  end
end