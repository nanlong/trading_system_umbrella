defmodule TradingApi.Sina.GFuture do
  @moduledoc """
  TradingApi.Sina.GFuture.get("list")
  TradingApi.Sina.GFuture.get("dayk", symbol: "CL")
  """
  use HTTPotion.Base

  @list_api "http://gu.sina.cn/hq/api/openapi.php/FuturesService.getGlobal"
  @dayk_api "http://stock2.finance.sina.com.cn/futures/api/jsonp.php/data/GlobalFuturesService.getGlobalFuturesDailyKLine"
  
  def process_url("list", _query) do
    @list_api
  end
  
  def process_url("dayk", query) do
    query = [
      symbol: Keyword.get(query, :symbol)
    ]

    process_url(@dayk_api, query)
  end

  def process_url(url, query) do
    process_url(url)
    |> prepend_protocol
    |> append_query_string([query: query])
  end

  def process_response_body(body) do
    body
    |> IO.iodata_to_binary()
    |> decode()
  end

  def decode("data" <> data) do
    data = String.slice(data, 1..-3)

    ~r/(?<={|,)\w+(?=:)/
    |> Regex.replace(data, "\"\\g{0}\"")
    |> Poison.decode()
  end

  def decode(data) do
    Poison.decode(data)
  end
end