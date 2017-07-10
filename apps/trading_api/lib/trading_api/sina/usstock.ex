defmodule TradingApi.Sina.USStock do
  @moduledoc """
  TradingApi.Sina.USStock.get("trade_days")
  TradingApi.Sina.USStock.get("list", page: 1)
  TradingApi.Sina.USStock.get("daily_k", symbol: "fb")
  TradingApi.Sina.USStock.get("min_k", symbol: "fb", type: 5)
  TradingApi.Sina.USStock.get("realtime", stocks: ["FB", "BABA"])
  """
  use HTTPotion.Base

  @k_service "http://stock.finance.sina.com.cn/usstock/api/jsonp_v2.php/<%= @varible %>/US_MinKService.<%= @method %>"
  @category_service "http://stock.finance.sina.com.cn/usstock/api/jsonp.php/List/US_CategoryService.<%= @method %>"
  @open_api "http://stock.finance.sina.com.cn/usstock/api/openapi.php/US_MinKService.getTradeDays"
  @realtime_api "http://hq.sinajs.cn/"

  def process_url("trade_days", _query) do
    process_url(@open_api, [start_day: "2000-01-01", end_day: Date.utc_today |> Date.to_string])
  end

  def process_url("list", query) do
    url = EEx.eval_string(@category_service, assigns: [method: "getList"])
    process_url(url, query)
  end
  
  def process_url("daily_k", query) do
    url = EEx.eval_string(@k_service, assigns: [varible: "DailyK", method: "getDailyK"])
    process_url(url, query)
  end
  
  def process_url("min_k", query) do
    url = EEx.eval_string(@k_service, assigns: [varible: "MinK", method: "getMinK"])
    process_url(url, query)
  end

  @doc """
  stocks: ["AAPL", "BABA"]
  """
  def process_url("realtime", [stocks: stocks]) do
    # stocks max 932
    list =
      stocks
      |> Enum.take(932)
      |> Enum.map(fn(x) -> "usr_" <> String.downcase(x) end)
      |> Enum.join(",")

    @realtime_api <> "/?list=" <> list
  end
  
  def process_url(url, query) do
    process_url(url)
    |> prepend_protocol
    |> append_query_string([query: query])
  end

  def process_response_body(body) when is_list(body), do: :iconv.convert("gbk", "utf-8", body) |> process_response_body
  def process_response_body(body), do: body |> IO.iodata_to_binary |> to_json

  defp to_json("List(null);"), do: []
  defp to_json("DailyK(null);"), do: []
  defp to_json("MinK(null);"), do: []
  defp to_json("var hq_str" <> _ = data) do
    # 中文名称 cname
    # 价格 price
    # 涨跌额 diff
    # 时间 datetime
    # 涨跌幅 chg
    # 开盘价 open_price
    # 最高价 highest_price
    # 最低价 lowest_price
    # 52周最高 week_52_highest
    # 52周最低 week_52_lowest
    # 成交量 volume
    # 10日均量 volume_10_avg
    # 市值 market_cap
    # 每股收益
    # 市盈率 pe
    # --
    # 贝塔系数 beta
    # 股息 dividend
    # 收益率 yield
    # 股本 capital
    # --
    # 盘前价格
    # 盘前涨跌幅
    # 盘前涨跌额
    # 盘前时间
    # 前日收盘时间
    # 前收盘价格 
    # 盘前成交量

    # ["苹果", "144.1800", "1.02", "2017-07-08 08:19:19", "1.4500", "142.9000",
    # "144.7500", "142.9000", "156.6500", "96.4200", "19201712", "23030822",
    # "756945000000", "8.33", "17.31", "0.00", "1.44", "2.28", "1.60", "5250000000",
    # "63.00", "144.2500", "0.05", "0.07", "Jul 07 08:00PM EDT",
    # "Jul 07 04:00PM EDT", "142.7300", "892519.00"]
    keys = 
      [:cname, :price, :diff, :datetime, :chg, :open_price,
      :highest_price, :lowest_price, :year_highest, :year_lowest, :volume, :volume_10_avg,
      :market_cap, nil, :pe, nil, :beta, :dividend, :yield, :capital,
        nil, nil, nil, nil, nil,
      :pre_close_datetime, :pre_close_price, nil]
    
    symbols = 
      Regex.scan(~r/usr_(.*)=/, data)
      |> Enum.map(fn([_, symbol]) -> String.upcase(symbol) end)
    
    data_list =
      Regex.scan(~r/=\"(.*)\";/, data)
      |> Enum.map(fn([_, str]) -> String.split(str, ",") end)
    
    symbols
    |> Enum.zip(data_list)
    |> Enum.map(fn({symbol, list}) -> 
      ([:symbol] ++ keys)
      |> Enum.zip([symbol] ++ list ) 
      |> Enum.into(%{})
      |> Map.delete(:nil)
      |> Map.update!(:price, &String.to_float(&1))
      |> Map.update!(:open_price, &String.to_float(&1))
      |> Map.update!(:highest_price, &String.to_float(&1))
      |> Map.update!(:lowest_price, &String.to_float(&1))
      |> Map.update!(:year_highest, &String.to_float(&1))
      |> Map.update!(:year_lowest, &String.to_float(&1))
      |> Map.update!(:volume, &String.to_integer(&1))
      |> Map.update!(:volume_10_avg, &String.to_integer(&1))
      |> Map.update!(:market_cap, &String.to_integer(&1))
    end)
  end
  defp to_json("List" <> data), do: data |> decode_json |> update_key("List")
  defp to_json("DailyK" <> data), do: data |> decode_json |> update_key("DailyK")
  defp to_json("MinK" <> data), do: data |> decode_json |> update_key("MinK")
  defp to_json(data), do: data |> Poison.decode |> update_key("TradeDays")

  defp decode_json("((" <> data) do
    data
    |> String.slice(0..-4)
    |> String.replace("null", "\"null\"")
    |> String.replace(":[", "\":[")
    |> String.replace("{", "{\"")
    |> String.replace("\",", "\",\"")
    |> String.replace(":\"", "\":\"")
    |> String.replace("\\'", "\'")
    |> Poison.decode
  end

  defp decode_json(data) do
    data
    |> String.slice(1..-3)
    |> String.replace("{", "{\"")
    |> String.replace("\",", "\",\"")
    |> String.replace(":\"", "\":\"")
    |> Poison.decode
  end

  defp update_key({:ok, data}, "List") do
    %{
      count: Map.get(data, "count") |> String.to_integer,
      data: Enum.map(Map.get(data, "data"), fn(x) -> 
        %{
          symbol: Map.get(x, "symbol"),
          name: Map.get(x, "name"),
          cname: Map.get(x, "cname"),
          category: map_get(x, "category"),
          pre_close_price: Map.get(x, "preclose"),
          open_price: Map.get(x, "open"),
          highest_price: Map.get(x, "high"),
          lowest_price: Map.get(x, "low"),
          diff: Map.get(x, "diff"),
          chg: Map.get(x, "chg"),
          amplitude: Map.get(x, "amplitude"),
          volume: Map.get(x, "volume"),
          market_cap: Map.get(x, "mktcap"),
          pe: map_get(x, "pe"),
          market: Map.get(x, "market"),
        }
      end)
    }
  end

  defp update_key({:ok, data}, "DailyK") do
    Enum.map(data, fn(x) -> 
      %{
        date: Map.get(x, "d"),
        open_price: Map.get(x, "o"),
        close_price: Map.get(x, "c"),
        lowest_price: Map.get(x, "l"),
        highest_price: Map.get(x, "h"),
        volume: Map.get(x, "v"),
      }
    end)
  end

  defp update_key({:ok, data}, "MinK") do
    Enum.map(data, fn(x) -> 
      %{
        datetime: Map.get(x, "d"),
        open_price: Map.get(x, "o"),
        close_price: Map.get(x, "c"),
        lowest_price: Map.get(x, "l"),
        highest_price: Map.get(x, "h"),
        volume: Map.get(x, "v"),
      }
    end)
  end

  defp update_key({:ok, data}, "TradeDays") do
    get_in(data, ["result", "data"])
  end

  defp map_get(map, key) do
    case Map.get(map, key) do
      "null" -> ""
      value -> value
    end
  end
end