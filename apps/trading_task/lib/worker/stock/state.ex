defmodule TradingTask.Worker.Stock.State do
  @moduledoc """
  Exq.enqueue(Exq, "default", TradingTask.Worker.Stock.State, ["00001"])
  """
  alias TradingSystem.Repo
  alias TradingSystem.Markets
  alias TradingSystem.Markets.StockState
  require Logger
  
  def perform(symbol) do
    stock = Markets.get_stock(symbol: symbol)
    dayk_list = Markets.list_stock_dayk(symbol: symbol)
    state_list = Markets.list_stock_state(symbol: symbol)

    data =
      case List.last(state_list) do
        nil -> dayk_list
        state_last -> Enum.filter(dayk_list, &(Date.compare(&1.date, state_last.date) == :gt))
      end
      |> data_handler(dayk_list, state_list)
    
    data =
      case List.last(state_list) do
        nil -> data
        state_last -> Enum.filter(data, &(Date.compare(&1.date, state_last.date) == :gt))
      end
    
    data
    |> Enum.chunk_every(2500)
    |> Enum.map(fn(data_chunk) -> 
      {_num, results} = Repo.insert_all(StockState, data_chunk, returning: true)
      stock_state_id = results |> List.last() |> Map.get(:id)
      Markets.update_stock(stock, %{stock_state_id: stock_state_id})
    end)
  end

  def data_handler([], _dayk_list, results), do: results
  def data_handler([dayk | rest], dayk_list, results) when length(results) < 20 do
    atr20 = TradingKernel.tr(dayk)
    attrs = generate_attrs(dayk, dayk_list, atr20)
    data_handler(rest, dayk_list, results ++ [attrs])
  end
  def data_handler([dayk | rest], dayk_list, results) when length(results) == 20 do
    atr20 =
      (for item <- results, do: item.atr20)
      |> Enum.reduce(fn(x, y) -> Decimal.add(x, y) end)
      |> Decimal.div(Decimal.new(20))
      |> Decimal.round(2)
    
    attrs = generate_attrs(dayk, dayk_list, atr20)
    data_handler(rest, dayk_list, results ++ [attrs])
  end
  def data_handler([dayk | rest], dayk_list, results) do
    pre_state = List.last(results)
    tr = TradingKernel.tr(dayk)
    atr20 = TradingKernel.Common.atr(pre_state.atr20, tr, Decimal.new(20))
    attrs = generate_attrs(dayk, dayk_list, atr20)
    data_handler(rest, dayk_list, results ++ [attrs])
  end

  def list_stock_dayk_before(data, date: date, limit: limit) do
    data = Enum.reverse(data)
    cur_index = Enum.find_index(data, &(Date.compare(&1.date, date) == :eq))
    
    data
    |> Enum.slice(cur_index..cur_index + limit)
    |> Enum.reverse()
  end

  def generate_attrs(dayk, dayk_list, atr20) do
    history = list_stock_dayk_before(dayk_list, date: dayk.date, limit: 300)
    dc_history = if length(history) == 1, do: history, else: Enum.slice(history, 0..-2)

    dc10 = TradingKernel.dc(dc_history, 10)
    dc20 = TradingKernel.dc(dc_history, 20)
    dc60 = TradingKernel.dc(dc_history, 60)

    %{
      date: dayk.date,
      symbol: dayk.symbol,
      tr: TradingKernel.tr(dayk),
      atr20: atr20,
      ma5: TradingKernel.ma(history, 5),
      ma10: TradingKernel.ma(history, 10),
      ma20: TradingKernel.ma(history, 20),
      ma30: TradingKernel.ma(history, 30),
      ma50: TradingKernel.ma(history, 50),
      ma60: TradingKernel.ma(history, 60),
      ma120: TradingKernel.ma(history, 120),
      ma150: TradingKernel.ma(history, 150),
      ma240: TradingKernel.ma(history, 240),
      ma300: TradingKernel.ma(history, 300),
      dcu10: dc10.up,
      dca10: dc10.avg,
      dcl10: dc10.lower,
      dcu20: dc20.up,
      dca20: dc20.avg,
      dcl20: dc20.lower,
      dcu60: dc60.up,
      dca60: dc60.avg,
      dcl60: dc60.lower,
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now(),
    }
  end
end