defmodule TradingApi.Sina.USStock do
  @moduledoc """
  TradingApi.Sina.USStock.get("getMinK", symbol: "fb", type: 5)
  """
  use HTTPotion.Base

  @api "http://stock.finance.sina.com.cn/usstock/api/jsonp_v2.php/var%20data=/US_MinKService."

  def process_url(url, query) do
    process_url(@api <> url)
    |> prepend_protocol
    |> append_query_string([query: query])
  end

  def process_response_body(body) do
    data =
      body
      |> IO.iodata_to_binary
      |> String.slice(10..-3)
    
    if data == "null" do
      []
    else
      data
      |> String.replace("{", "{\"")
      |> String.replace("\",", "\",\"")
      |> String.replace(":\"", "\":\"")
      |> Poison.decode
      |> update_key
    end
  end

  defp update_key({:ok, data}) do
    Enum.map(data, fn(x) -> 
      %{
        "datetime" => Map.get(x, "d"),
        "open_price" => Map.get(x, "o"),
        "close_price" => Map.get(x, "c"),
        "lowest_price" => Map.get(x, "l"),
        "highest_price" => Map.get(x, "h"),
        "volume" => Map.get(x, "v"),
      }
    end)
  end
end