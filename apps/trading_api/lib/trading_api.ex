defmodule TradingApi do
  alias TradingApi.Sina.CNStock, as: SinaCNStock
  alias TradingApi.Sina.HKStock, as: SinaHKStock
  alias TradingApi.Sina.USStock, as: SinaUSStock
  require Logger
  
  def get(market, method, query \\ [])
  def get(market, method, query), do: get(market, method, query, 1, 10)
  defp get(market, method, query, retry_num, retry_max) when retry_num > retry_max, do: message(market, retry_max, method, query)
  defp get(market, method, query, retry_num, retry_max) do
    client =
      case market do
        :cn -> SinaCNStock
        :hk -> SinaHKStock
        :us -> SinaUSStock
      end

    try do
      case client.get(method, query) do
        %{body: body} = response -> response
        %{message: "req_timedout"} -> 
          :timer.sleep(1000)
          get(market, method, query, retry_num + 1, retry_max)
        _ -> []
      end
    rescue 
      e in BadMapError ->
        Logger.debug e
        Logger.debug "调用出错：method #{method}, query: #{inspect(query)}"
        get(market, method, query, retry_num + 1, retry_max)
    end
  end

  defp message(market, retry_max, method, query) do
    Logger.debug "#{market}接口 请求失败，超过重试次数 #{retry_max}"
    Logger.debug "#{market}接口 请求信息：method #{method}, query: #{inspect(query)}"
    []
  end
end
