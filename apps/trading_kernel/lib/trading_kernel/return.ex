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
  def cagr(current_account, base_account, years) do
    :math.pow(current_account / base_account, 1 / years) - 1
  end
end