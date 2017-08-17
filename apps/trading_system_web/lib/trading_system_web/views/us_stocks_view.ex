defmodule TradingSystem.Web.USStocksView do
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

  ## Example

    iex> alias TradingSystem.Web.StockView
    iex> state = %{dcu20: Decimal.new(167.51), atr20: Decimal.new(5.40), ma50: Decimal.new(1), ma300: Decimal.new(0)}
    iex> config = %{create_days: 20, atr_add_step: 0.5}
    iex> StockView.buy(state, config, 1)
    167.51
    iex> StockView.buy(state, config, 2)
    170.21
    iex> StockView.buy(state, config, 3)
    172.91
    iex> StockView.buy(state, config, 4)
    175.61
  """
  def buy(state, config, position) do
    buy_signal = buy_signal(state, config)
    atr = atr(state, config)

    TradingKernel.Common.buy(
      buy_signal, atr, 
      tread: tread(state),
      position: position, 
      add_step: config.atr_add_step
    )
  end

  @doc """
  买入平均价

  ## Example

    iex> alias TradingSystem.Web.StockView
    iex> state = %{dcu20: Decimal.new(167.51), atr20: Decimal.new(5.40), ma50: Decimal.new(1), ma300: Decimal.new(0)}
    iex> config = %{create_days: 20, atr_add_step: 0.5}
    iex> StockView.buy_avg(state, config, 1)
    167.51
    iex> StockView.buy_avg(state, config, 2)
    168.86
    iex> StockView.buy_avg(state, config, 3)
    170.21
    iex> StockView.buy_avg(state, config, 4)
    171.56
  """
  def buy_avg(state, config, position) do
    buy_signal = buy_signal(state, config)
    atr = atr(state, config)

    TradingKernel.Common.buy_avg(
      buy_signal, atr, 
      tread: tread(state),
      position: position, 
      add_step: config.atr_add_step
    )
  end


  @doc """
  一次止损 4个ATR的损失，总账户的2%

  ## Example

    iex> alias TradingSystem.Web.StockView
    iex> state = %{dcu20: Decimal.new(167.51), atr20: Decimal.new(5.40), ma50: Decimal.new(1), ma300: Decimal.new(0)}
    iex> config = %{create_days: 20, atr_add_step: 0.5, atr_stop_step: 4}
    iex> StockView.stop_loss(state, config, 1)
    145.91
    iex> StockView.stop_loss(state, config, 2)
    158.06
    iex> StockView.stop_loss(state, config, 3)
    163.01
    iex> StockView.stop_loss(state, config, 4)
    166.16
  """
  def stop_loss(state, config, position) do
    buy_signal = buy_signal(state, config)
    atr = atr(state, config)

    TradingKernel.Common.stop_loss(
      buy_signal, atr, 
      tread: tread(state),
      position: position, 
      add_step: config.atr_add_step, 
      stop_step: config.atr_stop_step
    )
  end

  @doc """
  单位规模

  ## Example

    iex> alias TradingSystem.Web.StockView
    iex> state = %{dcu20: Decimal.new(167.51), atr20: Decimal.new(5.40)}
    iex> config = %{account: 100000, atr_account_ratio: 0.5}
    iex> StockView.unit(state, config)
    93
  """
  def unit(state, config) do
    atr = atr(state, config)

    TradingKernel.Common.unit(
      config.account, 
      atr, 
      config.atr_account_ratio
    )
  end

  @doc """
  单位成本

  ## Example

    iex> alias TradingSystem.Web.StockView
    iex> state = %{dcu20: Decimal.new(167.51), atr20: Decimal.new(5.40), ma50: Decimal.new(1), ma300: Decimal.new(0)}
    iex> config = %{account: 100000, create_days: 20, atr_account_ratio: 0.5, atr_add_step: 0.5}
    iex> StockView.unit_cost(state, config, 1)
    15578.43
    iex> StockView.unit_cost(state, config, 2)
    15829.53
    iex> StockView.unit_cost(state, config, 3)
    16080.63
    iex> StockView.unit_cost(state, config, 4)
    16331.73
  """
  def unit_cost(state, config, position) do
    buy_signal = buy_signal(state, config)
    atr = atr(state, config)

    TradingKernel.Common.unit_cost(
      config.account, buy_signal, atr,
      tread: tread(state),
      position: position,
      atr_account_ratio: config.atr_account_ratio,
      add_step: config.atr_add_step
    )
  end

  @doc """
  总成本

  ## Example

    iex> alias TradingSystem.Web.StockView
    iex> state = %{dcu20: Decimal.new(167.51), atr20: Decimal.new(5.40), ma50: Decimal.new(1), ma300: Decimal.new(0)}
    iex> config = %{account: 100000, create_days: 20, atr_account_ratio: 0.5, atr_add_step: 0.5, position: 4}
    iex> StockView.all_cost(state, config)
    63820.32
  """
  def all_cost(state, config, position \\ 0) do
    range_end = if position > 0, do: position, else: config.position

    (for position <- 1..range_end, do: unit_cost(state, config, position)) 
    |> Enum.sum 
    |> Float.round(2)
  end

  def max_position(state, config) do
    if all_cost(state, config) < config.account do
      config.position
    else
      max_position(state, config, 1)
    end
  end
  defp max_position(state, config, position) do
    if all_cost(state, config, position + 1) > config.account do
      position
    else
      max_position(state, config, position + 1)
    end
  end

  def float_to_string(float), do: :erlang.float_to_binary(float, decimals: 2)

  defp buy_signal(state, config) do
    prefix = if tread(state) == :bull, do: "dcu", else: "dcl"
    Decimal.to_float(Map.get(state, String.to_atom(prefix <> Integer.to_string(config.create_days))))
  end

  defp atr(state, _config) do
    Decimal.to_float(state.atr20)
  end

  defp tread(state) do
    if Decimal.cmp(state.ma50, state.ma300) == :lt, do: :bear, else: :bull
  end

  def tabs(conn) do
    [
      {"全部", "all", market_us_stocks_path(conn, :index, tab: "all")},
      {"适合做多的", "bull", market_us_stocks_path(conn, :index, tab: "bull")},
      {"适合做空的", "bear", market_us_stocks_path(conn, :index, tab: "bear")},
      {"黑名单", "blacklist", market_us_stocks_path(conn, :index, tab: "blacklist")}
    ]
  end
end
