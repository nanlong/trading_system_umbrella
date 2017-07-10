defmodule TradingSystem.Stocks do
  @moduledoc """
  The boundary for the Stocks system.
  """

  import Ecto.Query, warn: false
  alias TradingSystem.Repo

  alias TradingSystem.Stocks.USStock
  alias TradingSystem.Stocks.USStockDailyK
  alias TradingSystem.Stocks.USStock5MinK
  alias TradingSystem.Stocks.USStockStatus


  def list_usstock, do: Repo.all(USStock)

  def get_usstock!(attrs) when is_map(attrs), do: Repo.get_by!(USStock, attrs)
  def get_usstock!(symbol) when is_bitstring(symbol), do: Repo.get_by!(USStock, symbol: symbol)

  def create_usstock(attrs \\ %{}) do
    case Repo.get_by(USStock, symbol: attrs.symbol) do
      nil -> %USStock{}
      stock -> stock |> Map.put(:updated_at, NaiveDateTime.utc_now())
    end
    |> USStock.changeset(attrs)
    |> Repo.insert_or_update
  end


  def list_usstock_dailyk, do: Repo.all(USStockDailyK)
  def list_usstock_dailyk(symbol) do
    USStockDailyK
    |> where([k], k.symbol == ^symbol)
    |> order_by(asc: :date)
    |> Repo.all()
  end

  def history_usstock_dailyk(%{symbol: symbol, date: date}) do
    USStockDailyK
    |> where([k], k.symbol == ^symbol)
    |> where([k], k.date <= ^date)
    |> order_by(desc: :date)
    |> Repo.all()
    |> Enum.reverse()
  end

  def history_usstock_dailyk(%{symbol: symbol, date: date}, duration) do
    USStockDailyK
    |> where([k], k.symbol == ^symbol)
    |> where([k], k.date <= ^date)
    |> order_by(desc: :date)
    |> limit(^duration)
    |> Repo.all()
    |> Enum.reverse()
  end

  def get_last_usstock_dailyk(symbol) do
    USStockDailyK
    |> where([s], s.symbol == ^symbol)
    |> order_by(desc: :date)
    |> first
    |> Repo.one
  end

  def get_pre_close_price(symbol, date, default \\ 0) do
    usstock =
      USStockDailyK
      |> where([s], s.symbol == ^symbol)
      |> where([s], s.date < ^date)
      |> order_by(desc: :date)
      |> first
      |> Repo.one
    
    if usstock, do: usstock.close_price, else: default
  end
  
  def create_usstock_dailyk(%{symbol: symbol, date: date, open_price: open_price} = attrs) do
    unless Repo.get_by(USStockDailyK, symbol: symbol, date: date) do
      attrs = Map.put_new(attrs, :pre_close_price, get_pre_close_price(symbol, date, open_price))

      %USStockDailyK{}
      |> USStockDailyK.changeset(attrs)
      |> Repo.insert()
    else
      {:ok, nil}
    end
  end

  def list_usstock_5mink do
    Repo.all(USStock5MinK)
  end

  def get_usstock_5mink?(attrs) do
    case Repo.get_by(USStock5MinK, attrs) do
      nil -> false
      _ -> true
    end
  end

  def get_last_usstock_5mink(symbol) do
    USStock5MinK
    |> where([s], s.symbol == ^symbol)
    |> order_by(desc: :datetime)
    |> first
    |> Repo.one
  end
  
  def create_usstock_5mink(%{symbol: symbol, datetime: datetime} = attrs) do
    unless Repo.get_by(USStock5MinK, symbol: symbol, datetime: datetime) do
      %USStock5MinK{}
      |> USStock5MinK.changeset(attrs)
      |> Repo.insert()
    end
  end

  def list_usstock_status(date) do
    USStockStatus
    |> where([s], s.date == ^date)
    |> where([s], s.avg_50_gt_300 == true)
    |> where([s], s.n_ratio_60 > 0.01)
    |> join(:inner, [s1], s2 in USStock, s1.symbol == s2.symbol and s2.volume > 1800000 and s2.open_price > 2)
    |> order_by(desc: :n_ratio_60)
    |> preload(:stock)
    |> Repo.all
  end

  def get_usstock_status_last_date do
    query = from(s in USStockStatus, select: s.date, order_by: [desc: :date])

    query
    |> first()
    |> Repo.one()
  end

  def get_usstock_status(%{symbol: symbol, date: date}) do
    Repo.get_by(USStockStatus, symbol: symbol, date: date)
  end

  def get_usstock_status?(attrs) do
    if get_usstock_status(attrs), do: true, else: false
  end

  def get_pre_usstock_status(%{symbol: symbol, date: date}) do
    USStockStatus
    |> where([s], s.symbol == ^symbol)
    |> where([s], s.date < ^date)
    |> order_by(desc: :date)
    |> first()
    |> Repo.one()
  end

  def get_last_usstock_status(symbol) do
    USStockStatus
    |> where([s], s.symbol == ^symbol)
    |> order_by(desc: :date)
    |> first()
    |> Repo.one()
  end

  def create_usstock_status(attrs) do
    %USStockStatus{}
    |> USStockStatus.changeset(attrs)
    |> Repo.insert()
  end
end
