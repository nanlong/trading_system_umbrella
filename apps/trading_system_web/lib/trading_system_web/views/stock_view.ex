defmodule TradingSystem.Web.StockView do
  use TradingSystem.Web, :view
  use Timex

  alias TradingSystem.Stocks.Stock
  alias TradingSystem.Stocks.StockState

  def to_humanize(d) do
    Timex.from_now(d, "zh_CN")
  end

  def symbol(%Stock{symbol: symbol}) do
    String.replace(symbol, ".", "_")
  end 

  # def unit(%StockState{n: n}, account) do 
  #   Decimal.div(Decimal.new(account * 0.01), n) |> Decimal.round
  # end

  # def unit_price(%StockState{high_60: high_60} = status, account) do
  #   unit(status, account) |> Decimal.mult(high_60)
  # end

  # def stop_loss(%StockState{high_60: high_60, n: n}) do
  #   Decimal.sub(high_60, Decimal.mult(n, Decimal.new(2)))
  # end
end
