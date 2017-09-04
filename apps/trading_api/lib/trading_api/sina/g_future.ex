defmodule TradingApi.Sina.GFuture do
  @moduledoc """
  TradingApi.Sina.GFuture.get("list")
  TradingApi.Sina.GFuture.get("detail", symbol: "CL")
  TradingApi.Sina.GFuture.get("dayk", symbol: "CL")
  TradingApi.Sina.GFuture.get("lotSize", symbol: "CL")
  """
  use HTTPotion.Base

  @list_api "http://gu.sina.cn/hq/api/openapi.php/FuturesService.getGlobal"
  @dayk_api "http://stock2.finance.sina.com.cn/futures/api/jsonp.php/data/GlobalFuturesService.getGlobalFuturesDailyKLine"
  @detail_url "http://finance.sina.com.cn/futures/quotes/<%= @symbol %>.shtml"
  @detail_api "http://hq.sinajs.cn"

  def process_url("list", _query) do
    @list_api
  end
  
  def process_url("dayk", query) do
    query = [
      symbol: Keyword.get(query, :symbol)
    ]

    process_url(@dayk_api, query)
  end

  def process_url("lotSize", query) do
    query = [
      symbol: Keyword.get(query, :symbol)
    ]
    EEx.eval_string(@detail_url, assigns: query)
  end

  def process_url("detail", query) do
    rn = (System.system_time() / 1_000_000_000) |> round()
    list = "hf_#{query[:symbol]}"
    @detail_api <> "/?rn=#{rn}&list=#{list}"
  end

  def process_url(url, query) do
    process_url(url)
    |> prepend_protocol
    |> append_query_string([query: query])
  end

  def process_response_body(body) do
    body = :iconv.convert("gbk", "utf-8", body)

    {:ok, data} =
      body
      |> IO.iodata_to_binary()
      |> decode()

    data
  end

  def decode("data" <> data) do
    data = String.slice(data, 1..-3)

    ~r/(?<={|,)\w+(?=:)/
    |> Regex.replace(data, "\"\\g{0}\"")
    |> Poison.decode()
  end

  def decode("<!DOCTYPE html" <> _string = html) do
    name =
      html
      |> Floki.find(".futures-title .title")
      |> Floki.text()

    cname =
      html
      |> Floki.find("table#table-futures-basic-data tr:nth-child(1) td:nth-child(2)")
      |> Floki.text()


    lot_size_data =
      html
      |> Floki.find("table#table-futures-basic-data tr:nth-child(1) td:nth-child(4)")
      |> Floki.text() 
    
    lot_size =
      Regex.named_captures(~r/(?<lot_size>\d+)/, lot_size_data)
      |> Map.get("lot_size")
      |> String.to_integer()

    price_quote =
      html
      |> Floki.find("table#table-futures-basic-data tr:nth-child(1) td:nth-child(6)")
      |> Floki.text() 

    {trading_unit, price_quote} = 
      case price_quote do
        "美元美分/美金衡盎司" -> {"美元", "金衡盎司"}
        "美元美分/每金衡盎司" -> {"美元", "金衡盎司"}
        "美分和0.25美分/蒲式耳" -> {"美分", "蒲式耳"}
        string -> String.split(string, "/") |> List.to_tuple()
      end

    minimum_price_change = 
      html
      |> Floki.find("table#table-futures-basic-data tr:nth-child(2) td:nth-child(2)")
      |> Floki.text() 

    minimum_price_change =
      case minimum_price_change do
        "$0.0005/磅" -> "0.05美元"
        "电话交易：0.5美元/吨 电子盘：0.25美元/吨" -> "0.25美元"
        "电话交易：5美元/吨 电子盘：1美元/吨" -> "1美元"
        string -> String.split(string, "/") |> List.first()
      end

    data = %{
      "name" => name,
      "cname" => cname,
      "lot_size" => lot_size,
      "trading_unit" => trading_unit,
      "price_quote" => price_quote,
      "minimum_price_change" => minimum_price_change,
    }

    {:ok, data}
  end

  def decode("var hq_str_hf_" <> _ = data) do
    %{"symbol" => symbol} = Regex.named_captures(~r/hf_(?<symbol>\w+)=/, data)
    %{"data" => data} = Regex.named_captures(~r/"(?<data>.*)"/, data)
    data = data |> String.split(",") |> List.to_tuple()

    {price, _} = elem(data, 0) |> Float.parse()
    {chg, _} = elem(data, 1) |> Float.parse()
    {buy_price, _} = elem(data, 2) |> Float.parse()
    {sell_price, _} = elem(data, 3) |> Float.parse()
    {highest, _} = elem(data, 4) |> Float.parse()
    {lowest, _} = elem(data, 5) |> Float.parse()
    {pre_close, _} = elem(data, 7) |> Float.parse()
    {open, _} = elem(data, 8) |> Float.parse()
    {open_positions, _} = elem(data, 9) |> Integer.parse()
    {buy_positions, _} = elem(data, 10) |> Integer.parse()
    {sell_positions, _} = elem(data, 11) |> Integer.parse()
    name = elem(data, 13)
    diff = (price - pre_close) |> Float.round(2)
    datetime = "#{elem(data, 12)} #{elem(data, 6)}"
    lot_size = 
      TradingApi.Sina.GFuture.get("lotSize", symbol: symbol, timeout: 10_000)
      |> Map.get(:body) 
      |> Map.get("lot_size")

    {:ok, %{
      "symbol" => symbol,
      "name" => name,
      "lot_size" => lot_size,
      "price" => price,
      "open" => open,
      "highest" => highest,
      "lowest" => lowest,
      "pre_close" => pre_close,
      "diff" => diff,
      "chg" => chg,
      "buy_price" => buy_price,
      "sell_price" => sell_price,
      "open_positions" => open_positions,
      "buy_positions" => buy_positions,
      "sell_positions" => sell_positions,
      "datetime" => datetime,
    }}
  end

  def decode(data) do
    Poison.decode(data)
  end
end