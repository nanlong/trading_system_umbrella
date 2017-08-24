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

    case client.get(method, query) do
      %{body: _body} = response -> response
      error -> 
        IO.inspect "#{market} 接口错误, 第#{retry_num}次请求, method #{method}, query: #{inspect(query)}"
        IO.inspect "错误信息: #{inspect(error)}"
        :timer.sleep(1000)
        get(market, method, query, retry_num + 1, retry_max)
    end
  end

  defp message(market, retry_max, method, query) do
    IO.puts "#{market}接口 请求失败，超过重试次数 #{retry_max}"
    IO.puts "#{market}接口 请求信息：method #{method}, query: #{inspect(query)}"
    %{body: []}
  end
end
