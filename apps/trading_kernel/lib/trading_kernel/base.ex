defmodule TradingKernel.Base do
  @doc """
  True range (真实波动范围)

  ## Examples:
    iex> TradingKernel.Base.tr(110.06, 107.58, 105.2)
    #Decimal<4.86>
    iex> TradingKernel.Base.tr(Decimal.new(110.06), Decimal.new(107.58), 105.2)
    #Decimal<4.86>
    iex> TradingKernel.Base.tr(Decimal.new(110.06), Decimal.new(107.58), Decimal.new(105.2))
    #Decimal<4.86>
  """
  @spec tr(float | Decimal.t, float | Decimal.t, float | Decimal.t) :: Decimal.t
  def tr(pre_close_price, highest_price, lowest_price) when is_float(pre_close_price) or is_float(highest_price) or is_float(lowest_price) do
    pre_close_price = Decimal.new(pre_close_price)
    highest_price = Decimal.new(highest_price)
    lowest_price = Decimal.new(lowest_price)
    tr(pre_close_price, highest_price, lowest_price)
  end
  def tr(pre_close_price, highest_price, lowest_price) do
    d1 = Decimal.sub(highest_price, lowest_price)
    d2 = Decimal.sub(highest_price, pre_close_price) |> Decimal.abs
    d3 = Decimal.sub(pre_close_price, lowest_price) |> Decimal.abs

    Enum.max([d1, d2, d3])
  end

  @doc """
  Average true range (平均真实波动范围)

  ((cycle - 1) * pre_day_n + true_range) / cycle

  ## Examples:
    iex> TradingKernel.Base.atr(5.0, 4.0, 20)
    #Decimal<4.95>
    iex> TradingKernel.Base.atr(Decimal.new(5.0), Decimal.new(4.0), 20)
    #Decimal<4.95>
    iex> TradingKernel.Base.atr(Decimal.new(5.0), Decimal.new(4.0), Decimal.new(20))
    #Decimal<4.95>
  """
  @spec atr(float | Decimal.t, float | Decimal.t, integer) :: Decimal.t
  def atr(pre_atr, tr, duration) when is_float(pre_atr) or is_float(tr) or is_integer(duration) do
    pre_atr = Decimal.new(pre_atr)
    tr = Decimal.new(tr)
    duration = Decimal.new(duration)
    atr(pre_atr, tr, duration)
  end
  def atr(pre_atr, tr, duration) do
    duration
    |> Decimal.sub(Decimal.new(1))
    |> Decimal.mult(pre_atr)
    |> Decimal.add(tr)
    |> Decimal.div(duration)
  end

  @doc """
  ## 建仓单位:
    如果是股票单位为`股`
    如果是期货单位为`合约`
  
  ## 参数说明:
    account: 账户金额
    atr: 当天平均真实波动范围

  ## Examples:
    iex> TradingKernel.Base.unit(10000, 1.35)
    74
  """
  @spec unit(integer, float) :: integer
  def unit(account, atr) do
    {amount, _} = 
      (account * 0.01 / atr) 
      |> Float.to_string 
      |> Integer.parse

    amount
  end
end