defmodule TradingKernel.Common do
  @doc """
  True range (真实波动范围)

  ## Examples:
    iex> pre_close = Decimal.new(110.06)
    iex> highest = Decimal.new(107.58)
    iex> lowest = Decimal.new(105.2)
    iex> TradingKernel.Common.tr(pre_close, highest, lowest)
    #Decimal<4.86>
  """
  @spec tr(Decimal.t, Decimal.t, Decimal.t) :: Decimal.t
  def tr(pre_close, highest, lowest) do
    nums = [pre_close, highest, lowest]
    max = decimal_max(nums)
    min = decimal_min(nums)

    Decimal.sub(max, min) 
    |> Decimal.abs() 
    |> Decimal.round(2)
  end

  defp decimal_max(nums) do
    Enum.reduce(nums, fn(x, y) -> Decimal.max(x, y) end)
  end

  defp decimal_min(nums) do
    Enum.reduce(nums, fn(x, y) -> Decimal.min(x, y) end)
  end

  @doc """
  Average true range (平均真实波动范围)

  ((cycle - 1) * pre_day_n + true_range) / cycle

  ## Examples:
    iex> pre_atr = Decimal.new(5.0)
    iex> tr = Decimal.new(4.0)
    iex> duration = Decimal.new(20)
    iex> TradingKernel.Common.atr(pre_atr, tr, duration)
    #Decimal<4.95>
  """
  @spec atr(Decimal.t, Decimal.t, Decimal.t) :: Decimal.t
  def atr(pre_atr, tr, duration) do
    duration
    |> Decimal.sub(Decimal.new(1))
    |> Decimal.mult(pre_atr)
    |> Decimal.add(tr)
    |> Decimal.div(duration)
    |> Decimal.round(2)
  end

  @doc """
  ## 建仓单位:
    如果是股票单位为`股`
    如果是期货单位为`合约`
  
  ## 参数说明:
    account: 账户金额
    atr: 当天平均真实波动范围

  ## Examples:
    iex> TradingKernel.Common.unit(10000, 1.35)
    37
  """
  @spec unit(integer, float, float) :: integer
  def unit(account, atr, percent \\ 0.5, lot_size \\ 1) do
    (account * percent / 100 / atr / lot_size ) |> round() |> Kernel.*(lot_size)
  end

  @doc """
  获取一段时间内的最高价

  ## Example:
    iex> results = [%{highest: Decimal.new(2.2)}, %{highest: Decimal.new(1.1)}]
    iex> TradingKernel.Common.dc_up(results)
    #Decimal<2.2>
  """
  @spec dc_up(list) :: Decimal.t
  def dc_up(list) do
    (for item <- list, do: item.highest)
    |> Enum.reduce(fn(x, y) -> Decimal.max(x, y) end)
  end

  @doc """
  获取一段时间内的最低价

  ## Example:
    iex> results = [%{lowest: Decimal.new(2.2)}, %{lowest: Decimal.new(1.1)}]
    iex> TradingKernel.Common.dc_lower(results)
    #Decimal<1.1>
  """
  @spec dc_lower(list) :: Decimal.t
  def dc_lower(list) do
    (for item <- list, do: item.lowest)
    |> Enum.reduce(fn(x, y) -> Decimal.min(x, y) end)
  end

  @doc """
  获取平均价

  ## Example:
    iex> highest = Decimal.new(10.8)
    iex> lowest = Decimal.new(7.3)
    iex> TradingKernel.Common.dc_avg(highest, lowest)
    #Decimal<9.05>
  """
  @spec dc_avg(Decimal.t, Decimal.t) :: Decimal.t
  def dc_avg(highest, lowest) do
    highest
    |> Decimal.sub(lowest)
    |> Decimal.div(Decimal.new(2))
    |> Decimal.add(lowest)
    |> Decimal.round(2)
  end

  @doc """
  买入价

  ## Example:
    iex> buy_signal = 165.12
    iex> atr = 3.53
    iex> TradingKernel.Common.buy(buy_signal, atr)
    165.12
    iex> TradingKernel.Common.buy(buy_signal, atr, position: 2)
    166.88
    iex> TradingKernel.Common.buy(buy_signal, atr, position: 2, add_step: 1)
    168.65
  """
  def buy(buy_signal, atr, opts \\ []) do
    tread = Keyword.get(opts, :tread, :bull)
    position = Keyword.get(opts, :position, 1)
    add_step = Keyword.get(opts, :add_step, 0.5)

    num1 = buy_signal
    num2 = atr * add_step * (position - 1)

    (if tread == :bull, do: num1 + num2, else: num1 - num2)
    |> Float.round(2)
  end

  @doc """
  买入平均价

  ## Example:
    iex> buy_signal = 165.12
    iex> atr = 3.53
    iex> TradingKernel.Common.buy_avg(buy_signal, atr)
    165.12
    iex> TradingKernel.Common.buy_avg(buy_signal, atr, position: 2)
    166.0
    iex> TradingKernel.Common.buy_avg(buy_signal, atr, position: 2, add_step: 1)
    166.88
    iex> TradingKernel.Common.buy_avg(buy_signal, atr, position: 2, add_step: 1, tread: :bear)
    163.36
    iex> TradingKernel.Common.buy_avg(buy_signal, atr, position: 4, tread: :bear)
    162.47
  """
  def buy_avg(buy_signal, atr, opts \\ [])
  def buy_avg(buy_signal, atr, opts) do
    tread = Keyword.get(opts, :tread, :bull)
    position = Keyword.get(opts, :position, 1)
    add_step = Keyword.get(opts, :add_step, 0.5)

    num1 = buy_signal * position
    num2 = atr * add_step * Enum.sum(1..position - 1)
    
    cond do
      position == 1 -> num1
      tread == :bull -> (num1 + num2) / position
      tread == :bear -> (num1 - num2) / position
    end
    |> Float.round(2)
  end

  @doc """
  止损价

  ## Example:
    iex> buy_signal = 165.12
    iex> atr = 3.53
    iex> TradingKernel.Common.stop_loss(buy_signal, atr)
    151.0
    iex> TradingKernel.Common.stop_loss(buy_signal, atr, position: 2)
    158.94
    iex> TradingKernel.Common.stop_loss(buy_signal, atr, position: 2, stop_step: 2)
    162.47
  """
  def stop_loss(buy_signal, atr, opts \\ []) do
    tread = Keyword.get(opts, :tread, :bull)
    position = Keyword.get(opts, :position, 1)
    add_step = Keyword.get(opts, :add_step, 0.5)
    stop_step = Keyword.get(opts, :stop_step, 4)

    num1 = buy_avg(buy_signal, atr, tread: tread, position: position, add_step: add_step)
    num2 = atr * (stop_step / position)

    (if tread == :bull, do: num1 - num2, else: num1 + num2)
    |> Float.round(2)
  end


  @doc """
  单位价值

  ## Example:
    iex> account = 100000
    iex> buy_signal = 165.12
    iex> atr = 3.53
    iex> TradingKernel.Common.unit_cost(account, buy_signal, atr)
    23447.04
    iex> TradingKernel.Common.unit_cost(account, buy_signal, atr, position: 2)
    23696.96
  """
  def unit_cost(account, buy_signal, atr, opts \\ []) do
    atr_account_ratio = Keyword.get(opts, :atr_account_ratio, 0.5)
    lot_size = Keyword.get(opts, :lot_size, 1)

    num1 = unit(account, atr, atr_account_ratio, lot_size)
    num2 = buy(buy_signal, atr, opts)

    (num1 * num2) |> Float.round(2)
  end
end