defmodule TradingSystem.Web.StockView do
  use TradingSystem.Web, :view
  use Timex

  alias TradingSystem.Stocks.Stock

  def to_humanize(d) do
    Timex.from_now(d, "zh_CN")
  end

  def symbol(%Stock{symbol: symbol}) do
    String.replace(symbol, ".", "_")
  end 

  @doc """
  每涨0.5个ATR加一个单位，最多4个
  """
  def buy(state, position \\ 1) do
    buy_signal = Decimal.to_float(state.dcu60)
    atr = Decimal.to_float(state.atr20)
    (buy_signal + atr * (0.5 * (position - 1))) |> Float.round(2)
  end

  @doc """
  一次止损 4个ATR的损失，总账户的2%
  """
  def stop_loss(state, position \\ 1) do
    atr = Decimal.to_float(state.atr20)
    (buy_avg(state, position) - atr * (4 / position)) |> Float.round(2)
  end

  @doc """
  买入平均价
  """
  def buy_avg(state, position) do
    (for n <- 1..position, do: buy(state, n)) |> Enum.sum |> Kernel./(position) |> Float.round(2)
  end

  @doc """
  单位规模
  """
  def unit(account, state) do
    atr = Decimal.to_float(state.atr20)
    TradingKernel.Common.unit(account, atr)
  end

  @doc """
  单位成本
  """
  def unit_cost(account, state, position \\ 1) do
    (unit(account, state) * buy(state, position)) |> Float.round(2)
  end

  @doc """
  总成本
  """
  def all_cost(account, state) do
    (for n <- 1..4, do: unit_cost(account, state, n)) |> Enum.sum |> Float.round(2)
  end
end
