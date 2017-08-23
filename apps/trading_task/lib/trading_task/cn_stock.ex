defmodule TradingTask.CNStock do
  alias TradingApi.Sina.CNStock, as: Api

  @moduledoc """
  交易时间 周一至五9:30-11:30 PM1:00-3:00
  """
  alias TradingSystem.Markets

  def run() do
    # load_list()
    # load_dayk()
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
        category: "",
        open: get_in(x, ["ext", "open"]),
        highest: get_in(x, ["ext", "high"]),
        lowest: get_in(x, ["ext", "low"]),
        pre_close: get_in(x, ["ext", "prevclose"]),
        diff: get_in(x, ["ext", "change"]),
        chg: get_in(x, ["ext", "percent"]),
        amplitude: get_in(x, ["ext", "amplitude"]) |> to_string(),
        volume: get_in(x, ["ext", "totalVolume"]),
        market_cap: "",
        pe: ""
      }
  
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

  def load_dayk([]), do: nil
  def load_dayk([stock | rest]) do
    IO.puts stock.symbol

    dayk_list = 
      Api.get("dayk", symbol: stock.symbol)
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

    save_dayk(data)
    load_dayk(rest)
  end

  def save_dayk([]), do: nil
  def save_dayk([attrs | rest]) do
    if is_nil Markets.get_stock_dayk(symbol: attrs.symbol, date: attrs.date) do
      Markets.create_stock_dayk(attrs)
    end
    save_dayk(rest)
  end
end