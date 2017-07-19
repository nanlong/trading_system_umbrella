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

  def unit(%StockState{atr20: atr}, account) do
    TradingKernel.Common.unit(account, Decimal.to_float(atr))
  end

  def unit_price(%StockState{dcu60: dcu60} = status, account) do
    unit(status, account) * Decimal.to_float(dcu60)
  end

  def stop_loss(%StockState{dcu60: dcu60, atr20: atr20}) do
    Decimal.sub(dcu60, Decimal.mult(atr20, Decimal.new(2)))
  end
end
