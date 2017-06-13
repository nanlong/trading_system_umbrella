defmodule TradingApi.LiangYee.USStock do
  @moduledoc """
  美股数据获取接口

  获取5分钟k线
  TradingApi.LiangYee.USStock.get("/get5MinK", symbol: "AAPL")

  获取日k线
  TradingApi.LiangYee.USStock.get("/getDailyKBar", symbol: "AAPL", startDate: "2015-01-01", endDate: "2016-02-20")
  """
  use HTTPotion.Base
  
  @user_key Application.get_env(:trading_api, :liangyee_key)
  @api "http://stock.liangyee.com/bus-api/USStock/marketData/"
  # @min_start_date "2000-01-01"

  def process_url("/" <> url, query) do
    query =
      query
      |> Keyword.put_new(:"userKey", @user_key)
    
    process_url(@api <> url)
    |> prepend_protocol
    |> append_query_string([query: query])
  end

  def process_request_headers(headers) do
    Keyword.put(headers, :"User-Agent", "Elixir Client v0.1 by cainiao99")
  end

  @doc """
    字段说明：
    datetime 时间
    open_price:decimal 今开盘
    highest_price:decimal 最高价
    lowest_price:decimal 最低价
    close_price:decimal 今收盘
    turnover_vol:decimal 成交量
    chg_pct:decimal 涨跌幅
    pre_close_price:decimal 昨收盘
  """
  def process_response_body(body) do
    data_map =
      body 
      |> IO.iodata_to_binary 
      |> :jsx.decode
      |> Enum.into(%{})
    
    data_keys =
      case Map.get(data_map, "columns") do
        "交易时间,开盘价,最高价,最低价,收盘价,成交量" ->
          [:datetime, :open_price, :highest_price, :lowest_price, :close_price, :turnover_vol]
        "交易日,开盘价,收盘价,最高价,最低价,成交量,涨跌幅%" ->
          [:date, :open_price, :close_price, :highest_price, :lowest_price, :turnover_vol, :chg_pct]
        _ -> []
      end

    data_map
    |> Map.get("result")
    |> Enum.map(fn x -> Enum.zip(data_keys, String.split(x, ",")) |> Enum.into(%{}) end)
    |> pre_close_price
  end

  @doc """
  为数据加上‘昨收盘’字段
  """
  def pre_close_price(data) do
    len = length(data)

    pre_data = Enum.slice(data, 0, len - 1)
    now_data = Enum.slice(data, 1, len - 1)

    Enum.zip(pre_data, now_data)
    |> Enum.map(fn {pre_item, now_item} -> 
      Map.put_new(now_item, :pre_close_price, Map.get(pre_item, :close_price))
    end)
  end
end