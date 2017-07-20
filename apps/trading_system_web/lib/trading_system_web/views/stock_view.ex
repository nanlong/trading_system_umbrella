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

  def buy_price(state, position \\ 1)
  def buy_price(state, position) when position == 1 do
    Decimal.to_float(state.dcu60)
  end
  def buy_price(state, position) when position == 2 do
    (Decimal.to_float(state.dcu60) + Decimal.to_float(state.atr20) * 0.5) |> Float.round(2)
  end
  def buy_price(state, position) when position == 3 do
    (Decimal.to_float(state.dcu60) + Decimal.to_float(state.atr20)) |> Float.round(2)
  end
  def buy_price(state, position) when position == 4 do
    (Decimal.to_float(state.dcu60) + Decimal.to_float(state.atr20) * 1.5) |> Float.round(2)
  end

  def stop_loss(state, position \\ 1)
  def stop_loss(state, position) when position == 1 do
    (buy_avg_price(state, position) - Decimal.to_float(state.atr20) * 2) |> Float.round(2)
  end
  def stop_loss(state, position) when position == 2 do
    (buy_avg_price(state, position) - Decimal.to_float(state.atr20)) |> Float.round(2)
  end
  def stop_loss(state, position) when position == 3 do
    (buy_avg_price(state, position) - Decimal.to_float(state.atr20) * 0.66) |> Float.round(2)
  end
  def stop_loss(state, position) when position == 4 do
    (buy_avg_price(state, position) - Decimal.to_float(state.atr20) * 0.5) |> Float.round(2)
  end

  def buy_avg_price(state, position) do
    (for n <- 1..position, do: buy_price(state, n))
    |> Enum.sum
    |> Kernel./(position)
    |> Float.round(2)
  end

  def unit(account, %StockState{atr20: atr}) do
    TradingKernel.Common.unit(account, Decimal.to_float(atr))
  end

  def unit_price(account, state, position \\ 1)
  def unit_price(account, state, position) do
    (unit(account, state) * buy_price(state, position)) |> Float.round(2)
  end

  def all_price(account, state) do
    (for n <- 1..4, do: unit_price(account, state, n)) |> Enum.sum |> Float.round(2)
  end
end
