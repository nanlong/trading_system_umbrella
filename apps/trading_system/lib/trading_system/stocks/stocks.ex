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
  def list_stock_dailyk(symbol) do
    StockDailyK
    |> where([k], k.symbol == ^symbol)
    |> order_by(asc: :date)
    |> Repo.all()
  end

  def history_stock_dailyk(%{symbol: symbol, date: date}) do
    StockDailyK
    |> where([k], k.symbol == ^symbol)
    |> where([k], k.date <= ^date)
    |> order_by(asc: :date)
    |> Repo.all()
  end

  def history_stock_dailyk(%{symbol: symbol, date: date}, duration) do
    StockDailyK
    |> where([k], k.symbol == ^symbol)
    |> where([k], k.date <= ^date)
    |> order_by(desc: :date)
    |> limit(^duration)
    |> Repo.all()
    |> Enum.reverse()
  end

  def get_last_stock_dailyk(symbol) do
    StockDailyK
    |> where([s], s.symbol == ^symbol)
    |> order_by(desc: :date)
    |> first
    |> Repo.one
  end

  def get_pre_close_price(symbol, date, default \\ 0) do
    stock =
      StockDailyK
      |> where([s], s.symbol == ^symbol)
      |> where([s], s.date < ^date)
      |> order_by(desc: :date)
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
    |> order_by(desc: :datetime)
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
    list_stock_state(date)
  end
  def list_stock_state(date) do
    StockState
    |> where([s], s.date == ^date)
    |> where([s], s.avg_50_gt_300 == true)
    |> where([s], s.n_ratio_60 > 0.01)
    |> join(:inner, [s1], s2 in Stock, s1.symbol == s2.symbol and s2.volume > 1800000 and s2.open_price > 2)
    |> order_by(desc: :n_ratio_60)
    |> preload(:stock)
    |> Repo.all
  end

  def get_stock_state_last_date do
    query = from(s in StockState, select: s.date, order_by: [desc: :date])

    query
    |> first()
    |> Repo.one()
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
    |> order_by(desc: :date)
    |> first()
    |> Repo.one()
  end

  def get_last_stock_state(symbol) do
    StockState
    |> where([s], s.symbol == ^symbol)
    |> order_by(desc: :date)
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
end
