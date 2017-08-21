defmodule TradingApi.Sina.CNStock do
  @moduledoc """
  TradingApi.Sina.CNStock.get("list", page: 1)
  TradingApi.Sina.CNStock.get("dayk", symbol: "sh601677")
  TradingApi.Sina.CNStock.get("mink", symbol: "sh601677", scale: 5)
  TradingApi.Sina.CNStock.get("mink", symbol: "sh601677", scale: 60)
  """
  use HTTPotion.Base

  @list_api "http://gu.sina.cn/hq/api/openapi.php/StockV2Service.getNodeList"
  @k_api "http://money.finance.sina.com.cn/quotes_service/api/json_v2.php/CN_MarketData.getKLineData"


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

  def process_url(url, query) do
    process_url(url)
    |> prepend_protocol
    |> append_query_string([query: query])
  end

  def process_response_body(body) do
    data = IO.iodata_to_binary(body)

    {:ok, data} =
      ~r/(?<={|,)\w+(?=:)/
      |> Regex.replace(data, "\"\\g{0}\"")
      |> Poison.decode
      
    data
  end
end