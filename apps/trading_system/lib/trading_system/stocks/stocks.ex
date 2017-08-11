defmodule TradingSystem.Stocks do
  @moduledoc """
  The boundary for the Stocks system.
  """

  import Ecto.Query, warn: false
  alias TradingSystem.Repo

  alias TradingSystem.Stocks.Stock
  alias TradingSystem.Stocks.StockDailyK
  alias TradingSystem.Stocks.Stock5MinK
  alias TradingSystem.Stocks.StockState
  alias TradingSystem.Stocks.StockBlacklist
  alias TradingSystem.Stocks.StockStar

  def list_stock, do: Repo.all(Stock)

  def get_stock!(attrs) when is_map(attrs), do: Repo.get_by!(Stock, attrs)
  def get_stock!(symbol) when is_bitstring(symbol), do: Repo.get_by!(Stock, symbol: symbol)

  def create_stock(attrs \\ %{}) do
    case Repo.get_by(Stock, symbol: attrs.symbol) do
      nil -> %Stock{}
      stock -> stock |> Map.put(:updated_at, NaiveDateTime.utc_now())
    end
    |> Stock.changeset(attrs)
    |> Repo.insert_or_update
  end


  def list_stock_dailyk, do: Repo.all(StockDailyK)
  def list_stock_dailyk(symbol: symbol), do: list_stock_dailyk(symbol)
  def list_stock_dailyk(symbol) do
    StockDailyK
    |> where([k], k.symbol == ^symbol)
    |> order_by(asc: :inserted_at)
    |> Repo.all()
  end

  

  def history_stock_dailyk(%{symbol: symbol, date: date} = dailyk) do
    StockDailyK
    |> where([k], k.symbol == ^symbol)
    |> where([k], k.date < ^date)
    |> order_by(asc: :inserted_at)
    |> Repo.all()
    |> return_history(dailyk)
  end

  def history_stock_dailyk(%{symbol: symbol, date: date} = dailyk, duration) do
    StockDailyK
    |> where([k], k.symbol == ^symbol)
    |> where([k], k.date < ^date)
    |> order_by(desc: :inserted_at)
    |> limit(^duration)
    |> Repo.all()
    |> Enum.reverse()
    |> return_history(dailyk)
  end

  defp return_history([], cur), do: [cur]
  defp return_history(data, _cur), do: data

  def get_last_stock_dailyk(symbol) do
    StockDailyK
    |> where([s], s.symbol == ^symbol)
    |> order_by(desc: :inserted_at)
    |> first
    |> Repo.one
  end

  def get_pre_close_price(symbol, date, default \\ 0) do
    stock =
      StockDailyK
      |> where([s], s.symbol == ^symbol)
      |> where([s], s.date < ^date)
      |> order_by(desc: :inserted_at)
      |> first
      |> Repo.one
    
    if stock, do: stock.close, else: default
  end
  
  def create_stock_dailyk(%{symbol: symbol, date: date, open: open} = attrs) do
    unless Repo.get_by(StockDailyK, symbol: symbol, date: date) do
      attrs = Map.put_new(attrs, :pre_close, get_pre_close_price(symbol, date, open))

      %StockDailyK{}
      |> StockDailyK.changeset(attrs)
      |> Repo.insert()
    else
      {:ok, nil}
    end
  end

  def list_stock_5mink do
    Repo.all(Stock5MinK)
  end

  def get_stock_5mink?(attrs) do
    case Repo.get_by(Stock5MinK, attrs) do
      nil -> false
      _ -> true
    end
  end

  def get_last_stock_5mink(symbol) do
    Stock5MinK
    |> where([s], s.symbol == ^symbol)
    |> order_by(desc: :inserted_at)
    |> first
    |> Repo.one
  end
  
  def create_stock_5mink(%{symbol: symbol, datetime: datetime} = attrs) do
    unless Repo.get_by(Stock5MinK, symbol: symbol, datetime: datetime) do
      %Stock5MinK{}
      |> Stock5MinK.changeset(attrs)
      |> Repo.insert()
    end
  end

  def list_stock_state do
    date = get_stock_state_last_date()
    list_stock_state(date: date)
  end
  def list_stock_state([symbol: symbol]) do
    StockState
    |> where([s], s.symbol == ^symbol)
    |> order_by(asc: :inserted_at)
    |> preload(:stock)
    |> Repo.all()
  end
  def list_stock_state([date: date]) do
    StockState
    |> where([s], s.date == ^date)
    |> where([s], s.ma50 > s.ma300)
    |> where([s], fragment("? / ?", s.atr20, s.dcu60) > 0.02)
    |> where([s], not s.symbol in fragment("select symbol from stock_blacklist"))
    |> join(:inner, [s1], s2 in Stock, s1.symbol == s2.symbol and s2.volume > 3000000 and s2.open > 10)
    |> preload(:stock)
    |> Repo.all()
  end
  
  def stocks_paginate(params) do
    date = get_stock_state_last_date()

    query =
      Stock
      |> order_by(desc: :volume)
      |> join(:inner, [stock], state in StockState, stock.symbol == state.symbol and state.date == ^date)
      |> join(:inner, [stock], dailyk in StockDailyK, stock.symbol == dailyk.symbol and dailyk.date == ^date)
      |> select([stock, state, dailyk], {stock, state, dailyk})
    
    query =
      if Map.get(params, "q") do
        q = "%#{Map.get(params, "q")}%"

        query
        |> where([stock], ilike(stock.symbol, ^q) or ilike(stock.name, ^q) or ilike(stock.cname, ^q))
      else
        query
      end

    query =
      case Map.get(params, "tab") do
        "bull" -> where(query, [_stock, state], state.ma50 > state.ma300)
        "bear" -> where(query, [_stock, state], state.ma50 < state.ma300)
        _ -> query
      end

    Repo.paginate(query, params)
  end

  def get_stock_state_last_date do
    (from s in StockState, select: s.date, order_by: [desc: :date]) |> first() |> Repo.one()
  end

  def get_stock_state(%{symbol: symbol, date: date}) do
    Repo.get_by(StockState, symbol: symbol, date: date)
  end

  def get_stock_state?(attrs) do
    if get_stock_state(attrs), do: true, else: false
  end

  def get_pre_stock_state(%{symbol: symbol, date: date}) do
    StockState
    |> where([s], s.symbol == ^symbol)
    |> where([s], s.date < ^date)
    |> order_by(desc: :inserted_at)
    |> first()
    |> Repo.one()
  end

  def get_last_stock_state(symbol) do
    StockState
    |> where([s], s.symbol == ^symbol)
    |> order_by(desc: :inserted_at)
    |> first()
    |> Repo.one()
  end

  def create_stock_state(attrs) do
    %StockState{}
    |> StockState.changeset(attrs)
    |> Repo.insert()
  end

  def get_pre_count_stock_state(%{symbol: symbol, date: date}) do
    (from s in StockState, 
    where: s.symbol == ^symbol and s.date < ^date, 
    select: count(s.id))
    |> Repo.one()
  end

  def get_pre_history_stock_state(%{symbol: symbol, date: date}) do
    StockState
    |> where([s], s.symbol == ^symbol and s.date < ^date)
    |> Repo.all()
  end

  def blacklist?(symbol) do
    case Repo.get_by(StockBlacklist, symbol: symbol) do
      nil -> false
      _ -> true
    end
  end

  def star?(symbol) do
    case Repo.get_by(StockStar, symbol: symbol) do
      nil -> false
      _ -> true
    end
  end
end
