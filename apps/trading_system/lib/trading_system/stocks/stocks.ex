defmodule TradingSystem.Stocks do
  @moduledoc """
  The boundary for the Stocks system.
  """

  import Ecto.Query, warn: false
  alias TradingSystem.Repo

  alias TradingSystem.Stocks.USStock
  alias TradingSystem.Stocks.USStockDailyK

  @doc """
  Returns the list of us_stock_daily_prices.

  ## Examples

      iex> list_us_stock_daily_prices()
      [%USStockDailyK{}, ...]

  """
  def stock_list do
    query = from(USStockDailyK, distinct: :symbol, order_by: [desc: :date])
    Repo.all(query)
  end

  @doc """
  总资产大于1亿8千万的 前4000个股票列表
  """
  def stock_list(:dailyk, 4000) do
    USStock
    |> where([s], s.market_cap > 1_800_000_00)
    |> order_by(desc: :market_cap)
    |> limit(4000)
    |> Repo.all
  end

  def list_us_stock_daily_prices do
    Repo.all(USStockDailyK)
  end

  def list_us_stock_daily_prices(symbol, date, limit \\ 2000)
  def list_us_stock_daily_prices(symbol, date, limit) when is_bitstring(date), 
    do: list_us_stock_daily_prices(symbol, Date.from_iso8601!(date), limit)
  def list_us_stock_daily_prices(symbol, date, limit) do
    USStockDailyK
    |> where(symbol: ^symbol)
    |> where([s], s.date < ^date)
    |> order_by(desc: :date)
    |> limit(^limit)
    |> Repo.all
    |> Enum.reverse
  end

  @doc """
  Gets a single us_stock_daily_prices.

  Raises `Ecto.NoResultsError` if the Us stock daily prices does not exist.

  ## Examples

      iex> get_us_stock_daily_prices!(123)
      %USStockDailyK{}

      iex> get_us_stock_daily_prices!(456)
      ** (Ecto.NoResultsError)

  """
  def get_us_stock_daily_prices!(id), do: Repo.get!(USStockDailyK, id)
  def get_us_stock_daily_prices(attrs \\ []), do: Repo.get_by(USStockDailyK, attrs)
  def get_last_usstockdailyk(symbol) do
    USStockDailyK
    |> where([s], s.symbol == ^symbol)
    |> order_by(desc: :date)
    |> first
    |> Repo.one
  end

  def get_pre_close_price(symbol, date) do
    usstock =
      USStockDailyK
      |> where([s], s.symbol == ^symbol)
      |> where([s], s.date < ^date)
      |> order_by(desc: :date)
      |> first
      |> Repo.one
    
    if usstock, do: usstock.close_price, else: 0
  end
  @doc """
  Creates a us_stock_daily_prices.

  ## Examples

      iex> create_us_stock_daily_prices(%{field: value})
      {:ok, %USStockDailyK{}}

      iex> create_us_stock_daily_prices(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_us_stock_daily_prices(attrs \\ %{}) do
    %USStockDailyK{}
    |> USStockDailyK.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a us_stock_daily_prices.

  ## Examples

      iex> update_us_stock_daily_prices(us_stock_daily_prices, %{field: new_value})
      {:ok, %USStockDailyK{}}

      iex> update_us_stock_daily_prices(us_stock_daily_prices, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_us_stock_daily_prices(%USStockDailyK{} = us_stock_daily_prices, attrs) do
    us_stock_daily_prices
    |> USStockDailyK.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a USStockDailyK.

  ## Examples

      iex> delete_us_stock_daily_prices(us_stock_daily_prices)
      {:ok, %USStockDailyK{}}

      iex> delete_us_stock_daily_prices(us_stock_daily_prices)
      {:error, %Ecto.Changeset{}}

  """
  def delete_us_stock_daily_prices(%USStockDailyK{} = us_stock_daily_prices) do
    Repo.delete(us_stock_daily_prices)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking us_stock_daily_prices changes.

  ## Examples

      iex> change_us_stock_daily_prices(us_stock_daily_prices)
      %Ecto.Changeset{source: %USStockDailyK{}}

  """
  def change_us_stock_daily_prices(%USStockDailyK{} = us_stock_daily_prices) do
    USStockDailyK.changeset(us_stock_daily_prices, %{})
  end

  alias TradingSystem.Stocks.USStock

  def list_usstocks, do: Repo.all(USStock)
  def count_usstocks, do: from(s in USStock, select: count(s.id)) |> Repo.one!

  def get_usstock!(attrs) when is_map(attrs), do: Repo.get_by!(USStock, attrs)
  def get_usstock!(symbol) when is_bitstring(symbol), do: Repo.get_by!(USStock, symbol: symbol)

  def create_usstock(attrs \\ %{}) do
    %USStock{}
    |> USStock.changeset(attrs)
    |> Repo.insert()
  end

  def update_usstock(usstock, attrs) do
    usstock
    |> USStock.changeset(attrs)
    |> Repo.update()
  end

  alias TradingSystem.Stocks.USStock5MinK

  @doc """
  Returns the list of usstock_5mink.

  ## Examples

      iex> list_usstock_5mink()
      [%USStock5MinK{}, ...]

  """
  def list_usstock_5mink do
    Repo.all(USStock5MinK)
  end

  @doc """
  Gets a single us_stock5_min_k.

  Raises `Ecto.NoResultsError` if the Us stock5 min k does not exist.

  ## Examples

      iex> get_us_stock5_min_k!(123)
      %USStock5MinK{}

      iex> get_us_stock5_min_k!(456)
      ** (Ecto.NoResultsError)

  """
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
  @doc """
  Creates a us_stock5_min_k.

  ## Examples

      iex> create_us_stock5_min_k(%{field: value})
      {:ok, %USStock5MinK{}}

      iex> create_us_stock5_min_k(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_usstock_5mink(attrs \\ %{}) do
    %USStock5MinK{}
    |> USStock5MinK.changeset(attrs)
    |> Repo.insert()
  end

  def create_all_usstock_5mink(data), do: Repo.insert_all(USStock5MinK, data)
end
