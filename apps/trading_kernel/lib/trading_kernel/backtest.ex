defmodule TradingKernel.Backtest do
  @moduledoc """
  回测
  """
  alias TradingKernel.Common
  alias TradingSystem.Stocks
  alias Decimal, as: D
  require Logger

  def run(symbol, options \\ []) do
    config = %{
      begin_date: Keyword.get(options, :begin_date, ~D[2000-07-28]),
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
      start_index = Enum.find_index(dailyk, fn x -> Date.compare(x.date, config.begin_date) == :gt end)
      data = Enum.zip(dailyk, state) |> Enum.slice(start_index..-1)

      run(data, config, %{}, {})
    end
  end

  def run([], config, %{position: position} = status, history) when position > 0 do
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
      profit: Float.round(now_account - config.account, 2),
      history: history,
    }
  end
  def run([], config, status, history) do
    begin_date = Map.get(status, :begin_date)
    symbol = Map.get(status, :symbol)

    %{
      symbol: symbol,
      begin_date: begin_date,
      account: config.account,
      profit: Float.round(status.account - config.account, 2),
      history: history
    }
  end
  def run([{dailyk, state} | rest], config, status, history) do
    {status, history} =
      cond do
        is_create_position?(dailyk, state, status) ->
          # IO.inspect "#{dailyk.date} 建仓"
          begin_date = Map.get(status, :begin_date, state.date)
          account = Map.get(status, :account, config.account)
          atr = D.to_float(state.atr20)
          buy = D.to_float(state.dcu20)
          position = 1
          unit = Common.unit(account, atr)
          surplus = (account - Common.unit_cost(account, buy, atr, position, config.add_step)) |> Float.round
          
          status =
            status
            |> Map.put(:begin_date, begin_date)
            |> Map.put(:symbol, state.symbol)
            |> Map.put(:date, state.date)
            |> Map.put(:position, position)
            |> Map.put(:unit, unit)
            |> Map.put(:atr, atr)
            |> Map.put(:buy, buy)
            |> Map.put(:stop_loss, Common.stop_loss(buy, atr, position, config.add_step, config.stop_step))
            |> Map.put(:init_account, account)
            |> Map.put(:account, surplus)
            

          history = Tuple.append(history, %{
            date: state.date,
            action: "create",
            init_account: account,
            account: surplus,
            price: buy,
            unit: unit,
            position: position,
            market_cap: market_cap(dailyk.close, unit * position),
          })

          {status, history}

        is_add_position?(dailyk, status, config) ->
          # IO.inspect "#{dailyk.date} 加仓"
          init_account = Map.get(status, :init_account)
          account = Map.get(status, :account, 0)
          buy = Map.get(status, :buy, 0)
          atr = Map.get(status, :atr, 0)
          position = Map.get(status, :position, 0) + 1
          unit = Map.get(status, :unit)
          surplus = (account - Common.unit_cost(init_account, buy, atr, position, config.add_step)) |> Float.round

          status =
            status
            |> Map.put(:position, position)
            |> Map.put(:stop_loss, Common.stop_loss(buy, atr, position, config.add_step, config.stop_step))
            |> Map.put(:account, surplus)

          history = Tuple.append(history, %{
            date: state.date,
            action: "add",
            init_account: init_account,
            account: surplus,
            price: Common.buy(buy, atr, position, config.add_step),
            unit: Map.get(status, :unit),
            position: position,
            market_cap: market_cap(dailyk.close, unit * position),
          })

          {status, history}

        is_stop_loss?(dailyk, status) ->
          # IO.inspect "#{dailyk.date} 止损, 卖出价格: #{Map.get(status, :stop_loss)}"
          sell = (Map.get(status, :stop_loss) * Map.get(status, :unit) * Map.get(status, :position)) |> Float.round(2)
          surplus = (Map.get(status, :account) + sell) |> Float.round

          status =
            status
            |> Map.put(:position, 0)
            |> Map.put(:account, surplus)

          history = Tuple.append(history, %{
            date: state.date,
            action: "stop loss",
            init_account: Map.get(status, :init_account),
            account: surplus,
            price: Map.get(status, :stop_loss),
            unit: Map.get(status, :unit),
            position: Map.get(status, :position),
            market_cap: 0,
          })

          {status, history}
          
        is_stop_profit?(dailyk, state, status) ->
          # IO.inspect "#{dailyk.date} 止盈, 卖出价格：#{state.dcl10}"
          sell = (D.to_float(state.dcl10) * Map.get(status, :unit) * Map.get(status, :position)) |> Float.round(2)
          surplus = (Map.get(status, :account) + sell) |> Float.round

          status = 
            status
            |> Map.put(:position, 0)
            |> Map.put(:account, surplus)

          history = Tuple.append(history, %{
            date: state.date,
            action: "stop profit",
            init_account: Map.get(status, :init_account),
            account: surplus,
            price: D.to_float(state.dcl10),
            unit: Map.get(status, :unit),
            position: Map.get(status, :position),
            market_cap: 0
          })

          {status, history}

        true ->
          init_history_item = %{
            date: state.date,
            action: "empty",
            init_account: config.account,
            account: config.account,
            price: 0,
            unit: 0,
            position: 0,
            market_cap: 0
          }

          history_item = if tuple_size(history) > 0, do: elem(history, tuple_size(history) - 1), else: init_history_item
          history_item = Map.put(history_item, :market_cap, market_cap(dailyk.close, Map.get(status, :position, 0) * Map.get(status, :unit, 0)))

          history = Tuple.append(history, history_item)
          {status, history}
      end

    run(rest, config, status, history)
  end

  defp market_cap(price, amount) do
    D.to_float(price) * amount |> Float.round(2)
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

