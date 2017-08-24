defmodule TradingTask.Worker.CNStock.State do
  alias TradingSystem.Markets

  def perform(symbol) do
    dayk_list = Markets.list_stock_dayk(symbol: symbol)
    
    case Markets.list_stock_state(symbol: symbol) |> List.last() do
      nil -> dayk_list
      state_last -> Enum.filter(dayk_list, &(Date.compare(&1.date, state_last.date) == :gt))
    end
    |> data_handler(dayk_list)
    |> Enum.map(fn(attrs) -> Markets.create_stock_state(attrs) end)
  end

  def data_handler(data, dayk_list) do
    Enum.map(data, fn(dayk) -> 
      history = list_stock_dayk_before(dayk_list, date: dayk.date, limit: 300)
      dc_history = if length(history) == 1, do: history, else: Enum.slice(history, 0..-2)

      dc10 = TradingKernel.dc(dc_history, 10)
      dc20 = TradingKernel.dc(dc_history, 20)
      dc60 = TradingKernel.dc(dc_history, 60)

      %{
        date: dayk.date,
        symbol: dayk.symbol,
        tr: TradingKernel.tr(dayk),
        atr20: TradingKernel.atr(dayk),
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
      }
    end)
  end

  def list_stock_dayk_before(data, date: date, limit: limit) do
    data = Enum.reverse(data)
    cur_index = Enum.find_index(data, &(Date.compare(&1.date, date) == :eq))
    
    data
    |> Enum.slice(cur_index..cur_index + limit)
    |> Enum.reverse()
  end
end