defmodule TradingSystem.Web.StockView do
  use TradingSystem.Web, :view
  use Timex

  alias TradingSystem.Stocks
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

  ## Example

    iex> alias TradingSystem.Web.StockView
    iex> buy_signal = Decimal.new(167.51)
    iex> atr = Decimal.new(5.40)
    iex> StockView.buy(buy_signal, atr, 1)
    167.51
    iex> StockView.buy(buy_signal, atr, 2)
    170.21
    iex> StockView.buy(buy_signal, atr, 3)
    172.91
    iex> StockView.buy(buy_signal, atr, 4)
    175.61
  """
  def buy(buy_signal, atr, position \\ 1) do
    buy_signal = Decimal.to_float(buy_signal)
    atr = Decimal.to_float(atr)

    TradingKernel.Common.buy(buy_signal, atr, position, @add_step)
  end

  @doc """
  买入平均价

  ## Example

    iex> alias TradingSystem.Web.StockView
    iex> buy_signal = Decimal.new(167.51)
    iex> atr = Decimal.new(5.40)
    iex> StockView.buy_avg(buy_signal, atr, 1)
    167.51
    iex> StockView.buy_avg(buy_signal, atr, 2)
    168.86
    iex> StockView.buy_avg(buy_signal, atr, 3)
    170.21
    iex> StockView.buy_avg(buy_signal, atr, 4)
    171.56
  """
  def buy_avg(buy_signal, atr, position) do
    buy_signal = Decimal.to_float(buy_signal)
    atr = Decimal.to_float(atr)

    TradingKernel.Common.buy_avg(buy_signal, atr, position, @add_step)
  end

  @doc """
  一次止损 4个ATR的损失，总账户的2%

  ## Example

    iex> alias TradingSystem.Web.StockView
    iex> buy_signal = Decimal.new(167.51)
    iex> atr = Decimal.new(5.40)
    iex> StockView.stop_loss(buy_signal, atr, 1)
    145.91
    iex> StockView.stop_loss(buy_signal, atr, 2)
    158.06
    iex> StockView.stop_loss(buy_signal, atr, 3)
    163.01
    iex> StockView.stop_loss(buy_signal, atr, 4)
    166.16
  """
  def stop_loss(buy_signal, atr, position \\ 1) do
    buy_signal = Decimal.to_float(buy_signal)
    atr = Decimal.to_float(atr)

    TradingKernel.Common.stop_loss(buy_signal, atr, position, @add_step, @stop_step)
  end

  @doc """
  单位规模

  ## Example

    iex> alias TradingSystem.Web.StockView
    iex> atr = Decimal.new(5.40)
    iex> StockView.unit(0, atr)
    0
    iex> StockView.unit(100000, atr)
    93
  """
  def unit(account, _atr) when account <= 0, do: 0
  def unit(account, atr) do
    atr = Decimal.to_float(atr)
    
    TradingKernel.Common.unit(account, atr)
  end

  @doc """
  单位成本

  ## Example

    iex> alias TradingSystem.Web.StockView
    iex> account = 100000
    iex> buy_signal = Decimal.new(167.51)
    iex> atr = Decimal.new(5.40)
    iex> StockView.unit_cost(account, buy_signal, atr, 1)
    15578.43
    iex> StockView.unit_cost(account, buy_signal, atr, 2)
    15829.53
    iex> StockView.unit_cost(account, buy_signal, atr, 3)
    16080.63
    iex> StockView.unit_cost(account, buy_signal, atr, 4)
    16331.73
  """
  def unit_cost(account, buy_signal, atr, position \\ 1) do
    buy_signal = Decimal.to_float(buy_signal)
    atr = Decimal.to_float(atr)

    TradingKernel.Common.unit_cost(account, buy_signal, atr, position, @add_step)
  end

  @doc """
  总成本

  ## Example

    iex> alias TradingSystem.Web.StockView
    iex> account = 100000
    iex> buy_signal = Decimal.new(167.51)
    iex> atr = Decimal.new(5.40)
    iex> StockView.all_cost(account, buy_signal, atr)
    63820.32
  """
  def all_cost(account, buy_signal, atr) do
    (for position <- 1..@max_position, do: unit_cost(account, buy_signal, atr, position)) 
    |> Enum.sum 
    |> Float.round(2)
  end

  def float_to_string(float), do: :erlang.float_to_binary(float, decimals: 2)

  def blacklist?(symbol), do: Stocks.blacklist?(symbol)
  
  def star?(symbol), do: Stocks.star?(symbol)
end
