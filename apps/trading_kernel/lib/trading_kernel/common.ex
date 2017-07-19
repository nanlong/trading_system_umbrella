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
    74
  """
  @spec unit(integer, float) :: integer
  def unit(account, atr) do
    (account * 0.005 / atr) |> round()
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
end