defmodule TradingApi.Sina.USStock do
  @moduledoc """
  TradingApi.Sina.USStock.get("list", page: 1)
  TradingApi.Sina.USStock.get("daily_k", symbol: "fb")
  TradingApi.Sina.USStock.get("min_k", symbol: "fb", type: 5)
  """
  use HTTPotion.Base

  @k_service "http://stock.finance.sina.com.cn/usstock/api/jsonp_v2.php/<%= @varible %>/US_MinKService.<%= @method %>"
  @category_service "http://stock.finance.sina.com.cn/usstock/api/jsonp.php/List/US_CategoryService.<%= @method %>"
  
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

  def process_url(url, query) do
    process_url(url)
    |> prepend_protocol
    |> append_query_string([query: query])
  end

  def process_response_body(body) when is_list(body), do: :iconv.convert("gbk", "utf-8", body) |> process_response_body
  def process_response_body(body), do: body |> IO.iodata_to_binary |> to_json

  defp to_json("List" <> data), do: data |> decode_json |> update_key("List")
  defp to_json("DailyK" <> data), do: data |> decode_json |> update_key("DailyK")
  defp to_json("MinK" <> data), do: data |> decode_json |> update_key("MinK")
  defp to_json("(null);"), do: {:ok, []}

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

  defp map_get(map, key) do
    case Map.get(map, key) do
      "null" -> ""
      value -> value
    end
  end
end