defmodule TradingApi.Sina.CNStock do
  @moduledoc """
  TradingApi.Sina.CNStock.get("list", page: 1)
  TradingApi.Sina.CNStock.get("dayk", symbol: "sh601677")
  TradingApi.Sina.CNStock.get("mink", symbol: "sh601677", scale: 5)
  TradingApi.Sina.CNStock.get("mink", symbol: "sh601677", scale: 60)
  TradingApi.Sina.CNStock.get("detail", symbol: "sh601677")
  """
  use HTTPotion.Base

  @list_api "http://gu.sina.cn/hq/api/openapi.php/StockV2Service.getNodeList"
  @k_api "http://money.finance.sina.com.cn/quotes_service/api/json_v2.php/CN_MarketData.getKLineData"
  @detail_api "http://hq.sinajs.cn"

  def process_url("list", query) do
    query = [
      page: Keyword.get(query, :page, 1),
      num: Keyword.get(query, :num, 20)
    ]

    process_url(@list_api, query)
  end

  def process_url("dayk", query) do
    query = [
      symbol: Keyword.get(query, :symbol),
      scale: 240,
      datalen: 0
    ]
    
    process_url(@k_api, query)
  end

  @doc """
  scale: 5 | 15 | 30 | 60
  """
  def process_url("mink", query) do
    query = [
      symbol: Keyword.get(query, :symbol),
      scale: Keyword.get(query, :scale, 5),
      datalen: 0
    ]

    process_url(@k_api, query)
  end

  def process_url("detail", query) do
    rn = (System.system_time() / 1_000_000_000) |> round()
    list = "#{query[:symbol]},#{query[:symbol]}_i"
    @detail_api <> "/?rn=#{rn}&list=#{list}"
  end

  def process_url(url, query) do
    process_url(url)
    |> prepend_protocol
    |> append_query_string([query: query])
  end

  def process_response_body(body) do
    :iconv.convert("gbk", "utf-8", body) 
    |>  IO.iodata_to_binary()
    |> decode()
  end

  def decode("var" <> _ = data) do
    %{"symbol" => symbol} = Regex.named_captures(~r/str_(?<symbol>\w+)=/, data)

    [[_, d1], [_, d2]] = Regex.scan(~r/"(.*)"/, data)
    d1 = String.split(d1, ",") |> List.to_tuple()
    d2 = String.split(d2, ",") |> List.to_tuple()

    {open, _} = elem(d1, 1) |> Float.parse()
    {pre_close, _} = elem(d1, 2) |> Float.parse()
    {price, _} = elem(d1, 3) |> Float.parse()
    {highest, _} = elem(d1, 4) |> Float.parse()
    {lowest, _} = elem(d1, 5) |> Float.parse()
    {volume, _} = elem(d1, 8) |> Integer.parse()
    {amount, _} = elem(d1, 9) |> Float.parse()
    # 最近报告的每股净资产
    {navps, _} = elem(d2, 5) |> Float.parse()
    # 最近四个季度净利润
    {eps, _} = elem(d2, 13) |> Float.parse()
    # 总股本
    {total_capital, _} = elem(d2, 7) |> Float.parse()
    # 流通股本
    {cur_capital, _} = elem(d2, 8) |> Float.parse()
    # 总市值
    market_cap = (price * total_capital * 10_000) |> round()
    # 流通市值
    cur_market_cap = (price * cur_capital * 10_000) |> round()
    # 市盈率
    pe = (market_cap / eps / 100_000_000) |> Float.round(2)
    # 市净率
    pb = (price / navps) |> Float.round(2)
    # 换手率
    turnover = (volume / cur_capital / 100) |> Float.round(2)
    # 涨跌额
    diff = (price - pre_close) |> Float.round(2)
    # 涨跌幅
    chg = (diff / pre_close * 100) |> Float.round(2)
    # 振幅
    amplitude = ((highest - lowest) / pre_close * 100) |> Float.round(2)

    %{
      "symbol" => symbol,
      "name" => elem(d1, 0),
      "price" => price,
      "open" => open,
      "highest" => highest,
      "lowest" => lowest,
      "pre_close" => pre_close,
      "volume" => volume,
      "amount" => amount,
      "market_cap" => market_cap,
      "cur_market_cap" => cur_market_cap,
      "turnover" => turnover,
      "pb" => pb,
      "pe" => pe,
      "diff" => diff,
      "chg" => chg,
      "amplitude" => amplitude,
      "datetime" => "#{elem(d1, 30)} #{elem(d1, 31)}"
    }
  end

  def decode(data) do
    {:ok, data} =
      ~r/(?<={|,)\w+(?=:)/
      |> Regex.replace(data, "\"\\g{0}\"")
      |> Poison.decode
      
    data
  end
end