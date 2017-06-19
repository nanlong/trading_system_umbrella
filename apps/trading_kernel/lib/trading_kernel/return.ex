defmodule TradingKernel.Return do
  @moduledoc """
  回报量化
  """

  @doc """
  CAGR
  年均复合增长率(compound annual growth rate)

  ## Examples:
    iex> TradingKernel.Return.cagr(190000, 100000, 3)
    0.23856232963017088
  """
  @spec cagr(integer | float, integer | float, integer) :: float
  def cagr(now_account, before_account, years) do
    :math.pow(now_account / before_account, 1 / years) - 1
  end
end