defmodule TradingApi do
  alias TradingApi.Sina.USStock, as: SinaUSStock
  
  def get(method, query), do: get(method, query, 1, 10)
  defp get(method, query, retry_num, retry_max) when retry_num > retry_max do
    IO.puts "请求失败，超过重试次数 #{retry_max}"
    IO.puts "请求信息：method #{method}, query: #{inspect(query)}"
    []
  end
  defp get(method, query, retry_num, retry_max) do
    case SinaUSStock.get(method, query) do
      %{body: body} -> body
      %{message: "req_timedout"} -> 
        :timer.sleep(1000)
        get(method, query, retry_num + 1, retry_max)
      _ -> []
    end
  end
end
