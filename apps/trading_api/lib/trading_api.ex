defmodule TradingApi do
  alias TradingApi.Sina.USStock, as: SinaUSStock
  require Logger
  
  def get(method, query \\ [])
  def get(method, query), do: get(method, query, 1, 10)
  defp get(method, query, retry_num, retry_max) when retry_num > retry_max, do: message(retry_max, method, query)
  defp get(method, query, retry_num, retry_max) do
    try do
      case SinaUSStock.get(method, query) do
        %{body: body} -> body
        %{message: "req_timedout"} -> 
          :timer.sleep(1000)
          get(method, query, retry_num + 1, retry_max)
        _ -> []
      end
    rescue 
      e in BadMapError ->
        Logger.debug e
        Logger.debug "调用出错：method #{method}, query: #{inspect(query)}"
        get(method, query, retry_num + 1, retry_max)
    end
  end

  defp message(retry_max, method, query) do
    Logger.debug "请求失败，超过重试次数 #{retry_max}"
    Logger.debug "请求信息：method #{method}, query: #{inspect(query)}"
    []
  end
end
