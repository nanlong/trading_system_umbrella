defmodule TradingSystem.Web.StockView do
  use TradingSystem.Web, :view
  use Timex

  def to_humanize(d) do
    Timex.from_now(d, "zh_CN")
  end
end
