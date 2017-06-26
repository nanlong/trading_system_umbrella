defmodule TradingKernel.Turtle.Backtesting do
  @moduledoc """
  回测

    红色点为入场点；
    蓝色点为离场点；
    绿色点位止损点 
  """
  alias TradingKernel.DonchianChannel
  alias TradingKernel.Turtle


  def execute(day_history, min_history) do
    donchian_channel_20 = DonchianChannel.execute(day_history, 20)
    donchian_channel_10 = DonchianChannel.execute(day_history, 10)
    state =  %{status: :empty, red: [], blue: [], green: []}
    execute(day_history, min_history, donchian_channel_20, donchian_channel_10, state)
  end
  defp execute(_, [], _, _, state), do: state
  defp execute(day_history, [min_data | min_history], donchian_channel_20, donchian_channel_10, state) do
    dc20 = Enum.find(donchian_channel_20, fn(x) -> x.date == min_data.date end)
    dc10 = Enum.find(donchian_channel_10, fn(x) -> x.date == min_data.date end)

    n = 
      case state.status do
        :empty ->
          day_history
          |> Enum.split_with(&(&1.date < min_data.date))
          |> Turtle.n
        _ -> 0
      end
      
    state =
      cond do
        # 空仓状态下，入场，设置止损点
        # 价格超过最高价做多，或者价格低于最低价做空
        state.status == :empty and min_data.price > dc20.max_price ->
          state
          |> Map.put(:status, :long_position)
          |> Map.put(:stop_price, min_data.price - 2 * n)
          |> Map.update!(:red, &(&1 ++ [min_data]))

        state.status == :empty and min_data.price < dc20.min_price ->
          state
          |> Map.put(:status, :short_position)
          |> Map.put(:stop_price, min_data.price + 2 * n)
          |> Map.update!(:red, &(&1 ++ [min_data]))

        # 持仓状态下，价格低于止损点，离场
        (state.status == :long_position and min_data.price < state.stop_price) or
        (state.status == :short_position and min_data.price > state.stop_price) ->
          state
          |> Map.put(:status, :empty)
          |> Map.update!(:blue, &(&1 ++ [min_data]))

        # 持仓状态下, 价格低于唐奇安通道最低价格，则立场
        (state.status == :long_position and min_data.price < dc10.min_price) or
        (state.status == :short_position and min_data.price > dc10.max_price) ->
          state
          |> Map.put(:status, :empty)
          |> Map.update!(:green, &(&1 ++ [min_data]))
      end
    
    execute(day_history, min_history, donchian_channel_20, donchian_channel_10, state)
  end
end