defmodule TradingKernel.Backtest do

  alias TradingSystem.Accounts
  alias TradingSystem.Markets
  alias TradingKernel.Common


  def run(symbol, user) do
    {position, data, config} = init_data(symbol, user)
    trading(position, data, config, [])
  end

  def trading(_position, [], _config, results), do: results
  def trading(position, [data | rest], config, results) do
    {action, price, position} =
      cond do
        create_position?(position, data, config) -> 
          create_position(position, data, config)
        add_position?(position, data, config) -> 
          add_position(position, data, config)
        close_position?(position, data, config) -> 
          close_position(position, data, config)
        stop_loss?(position, data, config) -> 
          stop_loss(position, data, config)
        true -> 
          {"short", 0, position}
      end
    
    result = %{
      date: data.date,
      tread: position.tread,
      action: action,
      price: price,
      ratio: Float.round((cast(position, data) - config.account) / config.account, 2),
    }
    
    trading(position, rest, config, results ++ [result])
  end

  def cast(%{amount: amount} = position, _data) when amount == 0, do: position.account
  def cast(position, data) do
    %{account: account, tread: tread, amount: amount, unit: unit, avg_price: avg_price} = position
    %{close: close} = data
    price = Decimal.to_float(close)

    if tread == :bull do
      account + price * unit * amount
    else
      account + (avg_price * 2 - price) * unit * amount
    end
  end

  def init_data(symbol, user) do
    stock = Markets.get_stock(symbol: symbol)
    list_dailyk = Markets.list_stock_dayk(symbol: symbol)
    list_state = Markets.list_stock_state(symbol: symbol)
    config = Accounts.get_config(user_id: user.id) |> Map.put(:lot_size, stock.lot_size)
    begin_date = Timex.shift(DateTime.utc_now(), years: -3) |> Timex.to_date()

    data = 
      Enum.zip(list_dailyk, list_state)
      |> Enum.map(fn({dailyk, state}) -> 
        dailyk_map = Map.from_struct(dailyk)
        state_map = Map.from_struct(state)
        Map.merge(dailyk_map, state_map)
      end)
      |> Enum.filter(&(Date.compare(&1.date, begin_date) == :gt))
    
    {init_position(config.account, ""), data, config}
  end

  def init_position(account, tread) do
    %{
      account: account,
      tread: tread,
      amount: 0,
      unit: 0,
      atr: 0,
      break_price: 0,
      avg_price: 0,
      add_position_price: 0,
      stop_loss_price: 0,
    }
  end

  def create_position(position, data, config) do
    %{account: account} = position
    tread = tread(data)
    break_price = break_point(data, config)
    atr = data.atr20 |> Decimal.to_float()
    unit = Common.unit(account, atr, config.atr_account_ratio, config.lot_size)
    
    opts = [
      tread: tread, 
      position: 1, 
      add_step: config.atr_add_step, 
      stop_step: config.atr_stop_step,
      atr_account_ratio: config.atr_account_ratio
    ]    
    
    position = %{
      account: account - break_price * unit,
      tread: tread,
      amount: 1,
      unit: unit,
      atr: atr,
      break_price: break_price,
      avg_price: break_price,
      add_position_price: Common.buy(break_price, atr, Keyword.put(opts, :position, 2)),
      stop_loss_price: Common.stop_loss(break_price, atr, opts)
    }

    {"create", break_price, position}
  end

  def add_position(position, _data, config) do
    %{account: account, tread: tread, amount: amount, unit: unit, atr: atr, break_price: break_price, add_position_price: add_position_price} = position
    amount = amount + 1
    opts = [
      tread: tread, 
      position: amount, 
      add_step: config.atr_add_step, 
      stop_step: config.atr_stop_step,
      atr_account_ratio: config.atr_account_ratio
    ]

    position = %{
      account: account - add_position_price * unit,
      tread: tread,
      amount: amount,
      unit: unit,
      atr: atr,
      break_price: break_price,
      avg_price: Common.buy_avg(break_price, atr, opts),
      add_position_price: Common.buy(break_price, atr, Keyword.update!(opts, :position, &(&1 + 1))),
      stop_loss_price: Common.stop_loss(break_price, atr, opts)
    }

    {"add", add_position_price, position}
  end

  def close_position(position, data, config) do
    %{account: account, tread: tread, amount: amount, unit: unit, avg_price: avg_price} = position
    price = close_point(data, config)

    account =
      if tread == :bull do
        account + price * unit * amount
      else
        account + (avg_price * 2 - price) * unit * amount
      end
      
    position = init_position(account, tread)

    {"close", price, position}
  end

  def stop_loss(position, _data, _config) do
    %{account: account, tread: tread, amount: amount, unit: unit, avg_price: avg_price, stop_loss_price: stop_loss_price} = position

    account =
      if tread == :bull do
        account + stop_loss_price * unit * amount
      else
        account + (avg_price * 2 - stop_loss_price) * unit * amount
      end

    position = init_position(account, tread)

    {"stop", stop_loss_price, position}
  end

  def create_position?(position, data, config) do
    price = break_point(data, config)
    %{lowest: lowest, highest: highest} = data

    position.amount == 0 && 
    Decimal.to_float(lowest) < price && 
    price < Decimal.to_float(highest)
  end

  def add_position?(position, data, config) do
    price = position.add_position_price
    %{lowest: lowest, highest: highest} = data

    position.amount > 0 &&
    position.amount < config.position && 
    (if position.tread == :bull, 
    do: price < Decimal.to_float(highest), 
    else: Decimal.to_float(lowest) < price)
  end

  def close_position?(position, data, config) do
    price = close_point(data, config)
    %{lowest: lowest, highest: highest} = data

    position.amount > 0 &&
    (if position.tread == :bull, 
    do: Decimal.to_float(lowest) < price, 
    else: price < Decimal.to_float(highest))
  end

  def stop_loss?(position, data, _config) do
    price = position.stop_loss_price
    %{lowest: lowest, highest: highest} = data

    position.amount > 0 &&
    (if position.tread == :bull, 
    do: Decimal.to_float(lowest) < price, 
    else: price < Decimal.to_float(highest))
  end

  def break_point(data, config) do
    %{dcu20: dcu20, dcu60: dcu60, dcl20: dcl20, dcl60: dcl60} = data

    if bull?(data) do
      case config.create_days do
        20 -> dcu20
        60 -> dcu60
      end
    else
      case config.create_days do
        20 -> dcl20
        60 -> dcl60
      end
    end
    |> Decimal.to_float()
  end

  def close_point(data, config) do
    %{dcl10: dcl10, dcl20: dcl20, dcu10: dcu10, dcu20: dcu20} = data

    if bull?(data) do
      case config.close_days do
        10 -> dcl10
        20 -> dcl20
      end
    else
      case config.close_days do
        10 -> dcu10
        20 -> dcu20
      end
    end
    |> Decimal.to_float()
  end

  def tread(data) do
    if bull?(data), do: :bull, else: :bear
  end

  def bull?(data) do
    data.ma50 > data.ma300
  end
end