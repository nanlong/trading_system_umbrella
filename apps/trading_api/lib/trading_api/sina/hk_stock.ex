defmodule TradingApi.Sina.HKStock do
  @moduledoc """
  TradingApi.Sina.HKStock.get("dayk", symbol: "00293")
  """
  use HTTPotion.Base
  alias TradingApi.Sina.Decode

  @k_api "http://finance.sina.com.cn/stock/hkstock/<%= @symbol %>/klc_kl.js"

  def process_url("dayk", query) do
    symbol = Keyword.get(query, :symbol)
    EEx.eval_string(@k_api, assigns: [symbol: symbol])
  end

  def process_response_body(body) do
    data = IO.iodata_to_binary(body)
    
    ~r/var\sKLC_KL_[0-9]+=\"(?<data>\S+)";/
    |> Regex.named_captures(data)
    |> Map.get("data")
    |> Decode.decode()
  end
end