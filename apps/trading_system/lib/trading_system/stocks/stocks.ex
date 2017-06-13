defmodule TradingSystem.Stocks do
  @moduledoc """
  The boundary for the Stocks system.
  """

  import Ecto.Query, warn: false
  alias TradingSystem.Repo

  alias TradingSystem.Stocks.USStockDailyPrices

  @doc """
  Returns the list of us_stock_daily_prices.

  ## Examples

      iex> list_us_stock_daily_prices()
      [%USStockDailyPrices{}, ...]

  """
  def list_us_stock_daily_prices do
    Repo.all(USStockDailyPrices)
  end

  @doc """
  Gets a single us_stock_daily_prices.

  Raises `Ecto.NoResultsError` if the Us stock daily prices does not exist.

  ## Examples

      iex> get_us_stock_daily_prices!(123)
      %USStockDailyPrices{}

      iex> get_us_stock_daily_prices!(456)
      ** (Ecto.NoResultsError)

  """
  def get_us_stock_daily_prices!(id), do: Repo.get!(USStockDailyPrices, id)

  @doc """
  Creates a us_stock_daily_prices.

  ## Examples

      iex> create_us_stock_daily_prices(%{field: value})
      {:ok, %USStockDailyPrices{}}

      iex> create_us_stock_daily_prices(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_us_stock_daily_prices(attrs \\ %{}) do
    %USStockDailyPrices{}
    |> USStockDailyPrices.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a us_stock_daily_prices.

  ## Examples

      iex> update_us_stock_daily_prices(us_stock_daily_prices, %{field: new_value})
      {:ok, %USStockDailyPrices{}}

      iex> update_us_stock_daily_prices(us_stock_daily_prices, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_us_stock_daily_prices(%USStockDailyPrices{} = us_stock_daily_prices, attrs) do
    us_stock_daily_prices
    |> USStockDailyPrices.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a USStockDailyPrices.

  ## Examples

      iex> delete_us_stock_daily_prices(us_stock_daily_prices)
      {:ok, %USStockDailyPrices{}}

      iex> delete_us_stock_daily_prices(us_stock_daily_prices)
      {:error, %Ecto.Changeset{}}

  """
  def delete_us_stock_daily_prices(%USStockDailyPrices{} = us_stock_daily_prices) do
    Repo.delete(us_stock_daily_prices)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking us_stock_daily_prices changes.

  ## Examples

      iex> change_us_stock_daily_prices(us_stock_daily_prices)
      %Ecto.Changeset{source: %USStockDailyPrices{}}

  """
  def change_us_stock_daily_prices(%USStockDailyPrices{} = us_stock_daily_prices) do
    USStockDailyPrices.changeset(us_stock_daily_prices, %{})
  end
end
