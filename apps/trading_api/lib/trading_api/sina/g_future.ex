defmodule TradingApi.Sina.GFuture do
  @moduledoc """
  TradingApi.Sina.GFuture.get("list")
  TradingApi.Sina.GFuture.get("dayk", symbol: "CL")
  TradingApi.Sina.GFuture.get("lotSize", symbol: "CL")
  """
  use HTTPotion.Base

  @list_api "http://gu.sina.cn/hq/api/openapi.php/FuturesService.getGlobal"
  @dayk_api "http://stock2.finance.sina.com.cn/futures/api/jsonp.php/data/GlobalFuturesService.getGlobalFuturesDailyKLine"
  @detail_url "http://finance.sina.com.cn/futures/quotes/<%= @symbol %>.shtml"
  
  def process_url("list", _query) do
    @list_api
  end
  
  def process_url("dayk", query) do
    query = [
      symbol: Keyword.get(query, :symbol)
    ]

    process_url(@dayk_api, query)
  end

  def process_url("detail", query) do
    query = [
      symbol: Keyword.get(query, :symbol)
    ]
    EEx.eval_string(@detail_url, assigns: query)
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

    data = %{
      "name" => name,
      "cname" => cname,
      "lot_size" => lot_size
    }

    {:ok, data}
  end

  def decode(data) do
    Poison.decode(data)
  end
end