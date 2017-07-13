defmodule TradingKernel.Base do
  @doc """
  True range (真实波动范围)

  ## Examples:
    iex> TradingKernel.Base.tr(Decimal.new(110.06), Decimal.new(107.58), Decimal.new(105.2))
    #Decimal<4.86>
  """
  def tr(pre_close_price, highest_price, lowest_price) do
    d1 = Decimal.sub(highest_price, lowest_price)
    d2 = Decimal.sub(highest_price, pre_close_price) |> Decimal.abs
    d3 = Decimal.sub(pre_close_price, lowest_price) |> Decimal.abs

    Enum.reduce([d1, d2, d3], fn(x, y) -> Decimal.max(x, y) end)
    |> Decimal.round(2)
  end

  @doc """
  Average true range (平均真实波动范围)

  ((cycle - 1) * pre_day_n + true_range) / cycle

  ## Examples:
    iex> TradingKernel.Base.atr(Decimal.new(5.0), Decimal.new(4.0), Decimal.new(20))
    #Decimal<4.95>
  """
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