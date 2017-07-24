defmodule TradingSystem.Web.StockView do
  use TradingSystem.Web, :view
  use Timex

  alias TradingSystem.Stocks.Stock

  @max_position 4
  @add_step 0.5
  @stop_step 4

  def to_humanize(d) do
    Timex.from_now(d, "zh_CN")
  end

  def symbol(%Stock{symbol: symbol}) do
    String.replace(symbol, ".", "_")
  end 

  @doc """
  每涨0.5个ATR加一个单位，最多4个
  """
  def buy(buy_signal, atr, position \\ 1) do
    buy_signal = Decimal.to_float(buy_signal)
    atr = Decimal.to_float(atr)
    (buy_signal + atr * @add_step * (position - 1)) |> Float.round(2)
  end

  @doc """
  买入平均价
  """
  def buy_avg(buy_signal, _atr, position) when position == 1, do: Decimal.to_float(buy_signal)
  def buy_avg(buy_signal, atr, position) do
    buy_signal = Decimal.to_float(buy_signal)
    atr = Decimal.to_float(atr)
    ((buy_signal * position + atr * @add_step * Enum.sum(1..position - 1)) / position) |> Float.round(2)
  end

  @doc """
  一次止损 4个ATR的损失，总账户的2%
  """
  def stop_loss(buy_signal, atr, position \\ 1) do
    (buy_avg(buy_signal, atr, position) - Decimal.to_float(atr) * (@stop_step / position)) |> Float.round(2)
  end

  @doc """
  单位规模
  """
  def unit(account, _atr) when account <= 0, do: 0
  def unit(account, atr) do
    atr = Decimal.to_float(atr)
    TradingKernel.Common.unit(account, atr)
  end

  @doc """
  单位成本
  """
  def unit_cost(account, buy_signal, atr, position \\ 1) do
    (unit(account, atr) * buy(buy_signal, atr, position)) |> Float.round(2)
  end

  @doc """
  总成本
  """
  def all_cost(account, buy_signal, atr) do
    (for position <- 1..@max_position, do: unit_cost(account, buy_signal, atr, position)) 
    |> Enum.sum 
    |> Float.round(2)
  end

  def float_to_string(float), do: :erlang.float_to_binary(float, decimals: 2)
end
