defmodule TradingKernel.Backtest do
  @moduledoc """
  回测
  """
  alias TradingKernel.Common
  alias TradingSystem.Stocks
  alias Decimal, as: D
  import Logger

  def run(symbol, options \\ []) do
    config = %{
      account: Keyword.get(options, :account, 10000),
      max_position: Keyword.get(options, :max_position, 4),
      add_step: Keyword.get(options, :add_step, 0.5),
      stop_step: Keyword.get(options, :stop_step, 4)
    }

    # 读取状态数据
    state = Stocks.list_stock_state(symbol: symbol)
    # 读取日线数据
    dailyk = Stocks.list_stock_dailyk(symbol: symbol)
    if length(dailyk) < 300 do
      Logger.info "股票 #{symbol} 数据不足，跳过"
      %{symbol: symbol, begin_date: nil, account: config.account, profit: 0}
    else
      start_index = Enum.find_index(dailyk, fn x -> Date.compare(x.date, ~D[2016-07-28]) == :gt end)
      data = Enum.zip(dailyk, state) |> Enum.slice(start_index..-1)

      run(data, config, %{})
    end
  end

  def run([], config, %{position: position} = status) when position > 0 do
    begin_date = Map.get(status, :begin_date)
    symbol = Map.get(status, :symbol)
    buy = Map.get(status, :buy, 0)
    atr = Map.get(status, :atr, 0)
    unit = Map.get(status, :unit, 0)
    position = Map.get(status, :position, 0)
    now_account = (status.account + Common.buy_avg(buy, atr, position, config.add_step) * unit * position) |> Float.round(2) 

    %{
      symbol: symbol,
      begin_date: begin_date,
      account: config.account,
      profit: Float.round(now_account - config.account, 2)
    }
  end
  def run([], config, status) do
    begin_date = Map.get(status, :begin_date)
    symbol = Map.get(status, :symbol)

    %{
      symbol: symbol,
      begin_date: begin_date,
      account: config.account,
      profit: Float.round(status.account - config.account, 2)
    }
  end
  def run([{dailyk, state} | rest], config, status) do
    status =
      cond do
        is_create_position?(dailyk, state, status) ->
          # IO.inspect "#{dailyk.date} 建仓"
          begin_date = Map.get(status, :begin_date, state.date)
          account = Map.get(status, :account, config.account)
          atr = D.to_float(state.atr20)
          buy = D.to_float(state.dcu20)
          position = 1

          status
          |> Map.put(:begin_date, begin_date)
          |> Map.put(:symbol, state.symbol)
          |> Map.put(:date, state.date)
          |> Map.put(:position, position)
          |> Map.put(:unit, Common.unit(account, atr))
          |> Map.put(:atr, atr)
          |> Map.put(:buy, buy)
          |> Map.put(:stop_loss, Common.stop_loss(buy, atr, position, config.add_step, config.stop_step))
          |> Map.put(:init_account, account)
          |> Map.put(:account, account - Common.unit_cost(account, buy, atr, position, config.add_step))

        is_add_position?(dailyk, status, config) ->
          # IO.inspect "#{dailyk.date} 加仓"
          init_account = Map.get(status, :init_account)
          account = Map.get(status, :account, 0)
          buy = Map.get(status, :buy, 0)
          atr = Map.get(status, :atr, 0)
          position = Map.get(status, :position, 0) + 1

          status
          |> Map.put(:position, position)
          |> Map.put(:stop_loss, Common.stop_loss(buy, atr, position, config.add_step, config.stop_step))
          |> Map.put(:account, account - Common.unit_cost(init_account, buy, atr, position, config.add_step))

        is_stop_loss?(dailyk, status) ->
          # IO.inspect "#{dailyk.date} 止损, 卖出价格: #{Map.get(status, :stop_loss)}"
          sell = (Map.get(status, :stop_loss) * Map.get(status, :unit) * Map.get(status, :position)) |> Float.round(2)
          
          status
          |> Map.put(:position, 0)
          |> Map.update!(:account, &(&1 + sell))
        
        is_stop_profit?(dailyk, state, status) ->
          # IO.inspect "#{dailyk.date} 止盈, 卖出价格：#{state.dcl10}"
          sell = (D.to_float(state.dcl10) * Map.get(status, :unit) * Map.get(status, :position)) |> Float.round(2)

          status
          |> Map.put(:position, 0)
          |> Map.update!(:account, &(&1 + sell))

        true ->
          status
      end

    run(rest, config, status)
  end

  defp is_create_position?(dailyk, state, status) do
    D.cmp(state.ma50, state.ma300) == :gt and 
    D.cmp(dailyk.highest, state.dcu20) == :gt and
    Map.get(status, :position, 0) == 0
  end

  defp is_add_position?(dailyk, status, config) do
    init_account = Map.get(status, :init_account)
    account = Map.get(status, :account, 0)
    buy = Map.get(status, :buy, 0)
    atr = Map.get(status, :atr, 0)
    position = Map.get(status, :position, 0)
    break = Common.buy(buy, atr, position + 1, config.add_step)

    position > 0 and
    position < config.max_position and
    account > Common.unit_cost(init_account, buy, atr, position + 1, config.add_step) and
    D.to_float(dailyk.highest) > break
  end

  defp is_stop_loss?(dailyk, status) do
    Map.get(status, :position, 0) > 0 and
    Map.get(status, :stop_loss, 0) > D.to_float(dailyk.lowest)
  end

  defp is_stop_profit?(dailyk, state, status) do
    Map.get(status, :position, 0) > 0 and
    D.cmp(dailyk.lowest, state.dcl10) == :lt
  end
end

