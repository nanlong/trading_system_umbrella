defmodule TradingKernel.MockTrading do
  @moduledoc """
  模拟交易 使用s1系统规则，s2系统不需要模拟交易
  """

  @doc """
  参数：
    amaount 账户资金
    n 平均波幅
    now 当前时间
    day_history 所有日数据
    min_history 后续的分时数据

  return:
    盈利情况
    如果亏损，返回是n的倍数
  """
  @spec execute(integer, float | Decimal.t, DateTime.t, list, list) :: term
  def execute(_amaount, _n, _now, _day_history, _min_history) do
    # 以now为分割点，把day_history切成两部分

  end
end