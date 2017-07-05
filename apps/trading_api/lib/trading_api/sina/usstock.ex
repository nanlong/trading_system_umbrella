defmodule TradingApi.Sina.USStock do
  @moduledoc """
  TradingApi.Sina.USStock.get("getMinK", symbol: "fb", type: 5)
  TradingApi.Sina.USStock.get("getDailyK", symbol: "fb")
  """
  use HTTPotion.Base

  @api "http://stock.finance.sina.com.cn/usstock/api/jsonp_v2.php/<%= @varible %>/US_MinKService.<%= @method %>"

  def process_url("getMinK", query) do
    url = EEx.eval_string(@api, assigns: [varible: "MinK", method: "getMinK"])
    process_url(url, query)
  end

  def process_url("getDailyK", query) do
    url = EEx.eval_string(@api, assigns: [varible: "DailyK", method: "getDailyK"])
    process_url(url, query)
  end

  def process_url(url, query) do
    process_url(url)
    |> prepend_protocol
    |> append_query_string([query: query])
  end

  def process_response_body(body), do: body |> IO.iodata_to_binary |> to_json

  defp to_json("DailyK" <> data), do: data |> to_json |> update_key("DailyK")
  defp to_json("MinK" <> data), do: data |> to_json |> update_key("MinK")
  defp to_json("(null)"), do: []
  defp to_json(data) do
    data
    |> String.slice(1..-3)
    |> String.replace("{", "{\"")
    |> String.replace("\",", "\",\"")
    |> String.replace(":\"", "\":\"")
    |> Poison.decode
  end

  defp update_key({:ok, data}, "DailyK") do
    Enum.map(data, fn(x) -> 
      %{
        "date" => Map.get(x, "d"),
        "open_price" => Map.get(x, "o"),
        "close_price" => Map.get(x, "c"),
        "lowest_price" => Map.get(x, "l"),
        "highest_price" => Map.get(x, "h"),
        "volume" => Map.get(x, "v"),
      }
    end)
  end

  defp update_key({:ok, data}, "MinK") do
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