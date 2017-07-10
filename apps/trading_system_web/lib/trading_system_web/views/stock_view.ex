defmodule TradingSystem.Web.StockView do
  use TradingSystem.Web, :view
  use Timex

  alias TradingSystem.Stocks.USStock

  def to_humanize(d) do
    Timex.from_now(d, "zh_CN")
  end

  def symbol(%USStock{symbol: symbol}), do: String.replace(symbol, ".", "_")
end
