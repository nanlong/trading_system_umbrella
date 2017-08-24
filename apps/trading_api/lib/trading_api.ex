defmodule TradingApi do
  alias TradingApi.Sina.CNStock, as: SinaCNStock
  alias TradingApi.Sina.HKStock, as: SinaHKStock
  alias TradingApi.Sina.USStock, as: SinaUSStock
  
  
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
        %{body: _body} = response -> response
        %{message: "req_timedout"} -> 
          :timer.sleep(1000)
          get(market, method, query, retry_num + 1, retry_max)
        error -> 
          IO.inspect error
          %{body: []}
      end
    rescue 
      e in BadMapError ->
        IO.inspect e
        IO.puts "调用出错：method #{method}, query: #{inspect(query)}"
        get(market, method, query, retry_num + 1, retry_max)
    end
  end

  defp message(market, retry_max, method, query) do
    IO.puts "#{market}接口 请求失败，超过重试次数 #{retry_max}"
    IO.puts "#{market}接口 请求信息：method #{method}, query: #{inspect(query)}"
    %{body: []}
  end
end
