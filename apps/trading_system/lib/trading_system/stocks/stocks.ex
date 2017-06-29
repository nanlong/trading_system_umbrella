defmodule TradingSystem.Stocks do
  @moduledoc """
  The boundary for the Stocks system.
  """

  import Ecto.Query, warn: false
  alias TradingSystem.Repo

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

  def get_usstock!(attrs), do: Repo.get_by!(USStock, attrs)

  def create_usstock(attrs \\ %{}) do
    %USStock{}
    |> USStock.changeset(attrs)
    |> Repo.insert()
  end
end
