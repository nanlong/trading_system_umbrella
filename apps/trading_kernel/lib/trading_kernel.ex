defmodule TradingKernel do
  @moduledoc """
  Documentation for TradingKernel.
  """
  alias TradingKernel.Common
  alias TradingSystem.Stocks

  @doc """
  真实波幅
  """
  def tr(%{pre_close: pc, highest: h, lowest: l}) do
    Common.tr(pc, h, l)
  end

  @doc """
  平均真实波幅
  """
  def atr(dailyk, duration \\ 20) do
    # 1..20 计算tr
    # 21 计算 前面tr的平均
    # 22.. 用前面的atr
    pre_count = Stocks.get_pre_count_stock_state(dailyk)

    cond do
      pre_count < duration -> 
        tr(dailyk)
      pre_count == duration ->
        history = Stocks.get_pre_history_stock_state(dailyk)

        (for item <- history, do: item.atr20)
        |> Enum.reduce(fn(x, y) -> Decimal.add(x, y) end)
        |> Decimal.div(Decimal.new(20))
        |> Decimal.round(2)
      pre_count > duration -> 
        tr = tr(dailyk)

        pre_atr = 
          dailyk
          |> Stocks.get_pre_stock_state()
          |> Map.get(String.to_atom("atr" <> Integer.to_string(duration)))
        
        Common.atr(pre_atr, tr, Decimal.new(duration))
    end
  end

  @doc """
  唐奇安通道
  """
  def dc(history, duration) do
    data = list_slice(history, duration)
    up = Common.dc_up(data)
    lower = Common.dc_lower(data)
    avg = Common.dc_avg(up, lower)
    
    %{up: up, avg: avg, lower: lower}
  end

  @doc """
  移动平均
  """
  def ma(history, duration) do
    data = list_slice(history, duration)
    len = data |> length() |> Decimal.new()

    (for item <- data, do: item.close)
    |> Enum.reduce(fn(x, y) -> Decimal.add(x, y) end)
    |> Decimal.div(len)
    |> Decimal.round(2)
  end

  defp list_slice(list, range_end) do
    list
    |> Enum.reverse() 
    |> Enum.slice(0..range_end) 
    |> Enum.reverse()
  end
end
