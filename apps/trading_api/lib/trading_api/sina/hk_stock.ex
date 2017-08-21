defmodule TradingApi.Sina.HKStock do
  @moduledoc """
  TradingApi.Sina.HKStock.get("list")
  TradingApi.Sina.HKStock.get("dayk", symbol: "00293")
  """

  use HTTPotion.Base
  alias TradingApi.Sina.Decode

  @list_api "http://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/Market_Center.getHKStockData"
  @dayk_api "http://finance.sina.com.cn/stock/hkstock/<%= @symbol %>/klc_kl.js"

  def process_url("list", query) do
    query = [
      page: Keyword.get(query, :page, 1),
      num: Keyword.get(query, :num, 40),
      sort: Keyword.get(query, :sort, "symbol"),
      asc: Keyword.get(query, :asc, 1),
      node: Keyword.get(query, :node, "qbgg_hk")
    ]

    process_url(@list_api, query)
  end

  def process_url("dayk", query) do
    symbol = Keyword.get(query, :symbol)
    EEx.eval_string(@dayk_api, assigns: [symbol: symbol])
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

  def decode("var" <> _string = data) do
    ~r/var\sKLC_KL_[0-9]+=\"(?<data>\S+)";/
    |> Regex.named_captures(data)
    |> Map.get("data")
    |> Decode.decode()
  end

  def decode(data) do
    data = 
      :iconv.convert("gbk", "utf-8", data)
      |> String.replace("\\'", "\'")

    ~r/(?<={|,)\w+(?=:)/
    |> Regex.replace(data, "\"\\g{0}\"")
    |> IO.inspect()
    |> Poison.decode()
  end
end