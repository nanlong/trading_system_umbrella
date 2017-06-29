defmodule TradingSystem.StocksTest do
  use TradingSystem.DataCase

  alias TradingSystem.Stocks

  describe "us_stock_daily_prices" do
    alias TradingSystem.Stocks.USStockDailyK

    @valid_attrs %{chg_pct: "120.5", close_price: "120.5", date: ~D[2010-04-17], highest_price: "120.5", lowest_price: "120.5", open_price: "120.5", symbol: "some symbol", turnover_vol: 42, pre_close_price: "120.8"}
    @update_attrs %{chg_pct: "456.7", close_price: "456.7", date: ~D[2011-05-18], highest_price: "456.7", lowest_price: "456.7", open_price: "456.7", symbol: "some updated symbol", turnover_vol: 43, pre_close_price: "480.5"}
    @invalid_attrs %{chg_pct: nil, close_price: nil, date: nil, highest_price: nil, lowest_price: nil, open_price: nil, symbol: nil, turnover_vol: nil}

    def us_stock_daily_prices_fixture(attrs \\ %{}) do
      {:ok, us_stock_daily_prices} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Stocks.create_us_stock_daily_prices()

      us_stock_daily_prices
    end

    test "list_us_stock_daily_prices/0 returns all us_stock_daily_prices" do
      us_stock_daily_prices = us_stock_daily_prices_fixture()
      assert Stocks.list_us_stock_daily_prices() == [us_stock_daily_prices]
    end

    test "get_us_stock_daily_prices!/1 returns the us_stock_daily_prices with given id" do
      us_stock_daily_prices = us_stock_daily_prices_fixture()
      assert Stocks.get_us_stock_daily_prices!(us_stock_daily_prices.id) == us_stock_daily_prices
    end

    test "create_us_stock_daily_prices/1 with valid data creates a us_stock_daily_prices" do
      assert {:ok, %USStockDailyK{} = us_stock_daily_prices} = Stocks.create_us_stock_daily_prices(@valid_attrs)
      assert us_stock_daily_prices.chg_pct == 120.5
      assert us_stock_daily_prices.close_price == Decimal.new("120.5")
      assert us_stock_daily_prices.date == ~D[2010-04-17]
      assert us_stock_daily_prices.highest_price == Decimal.new("120.5")
      assert us_stock_daily_prices.lowest_price == Decimal.new("120.5")
      assert us_stock_daily_prices.open_price == Decimal.new("120.5")
      assert us_stock_daily_prices.symbol == "some symbol"
      assert us_stock_daily_prices.turnover_vol == 42
      assert us_stock_daily_prices.pre_close_price == Decimal.new("120.8")
    end

    test "create_us_stock_daily_prices/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stocks.create_us_stock_daily_prices(@invalid_attrs)
    end

    test "update_us_stock_daily_prices/2 with valid data updates the us_stock_daily_prices" do
      us_stock_daily_prices = us_stock_daily_prices_fixture()
      assert {:ok, us_stock_daily_prices} = Stocks.update_us_stock_daily_prices(us_stock_daily_prices, @update_attrs)
      assert %USStockDailyK{} = us_stock_daily_prices
      assert us_stock_daily_prices.chg_pct == 456.7
      assert us_stock_daily_prices.close_price == Decimal.new("456.7")
      assert us_stock_daily_prices.date == ~D[2011-05-18]
      assert us_stock_daily_prices.highest_price == Decimal.new("456.7")
      assert us_stock_daily_prices.lowest_price == Decimal.new("456.7")
      assert us_stock_daily_prices.open_price == Decimal.new("456.7")
      assert us_stock_daily_prices.symbol == "some updated symbol"
      assert us_stock_daily_prices.turnover_vol == 43
      assert us_stock_daily_prices.pre_close_price == Decimal.new("480.5")
    end

    test "update_us_stock_daily_prices/2 with invalid data returns error changeset" do
      us_stock_daily_prices = us_stock_daily_prices_fixture()
      assert {:error, %Ecto.Changeset{}} = Stocks.update_us_stock_daily_prices(us_stock_daily_prices, @invalid_attrs)
      assert us_stock_daily_prices == Stocks.get_us_stock_daily_prices!(us_stock_daily_prices.id)
    end

    test "delete_us_stock_daily_prices/1 deletes the us_stock_daily_prices" do
      us_stock_daily_prices = us_stock_daily_prices_fixture()
      assert {:ok, %USStockDailyK{}} = Stocks.delete_us_stock_daily_prices(us_stock_daily_prices)
      assert_raise Ecto.NoResultsError, fn -> Stocks.get_us_stock_daily_prices!(us_stock_daily_prices.id) end
    end

    test "change_us_stock_daily_prices/1 returns a us_stock_daily_prices changeset" do
      us_stock_daily_prices = us_stock_daily_prices_fixture()
      assert %Ecto.Changeset{} = Stocks.change_us_stock_daily_prices(us_stock_daily_prices)
    end
  end

  describe "usstocks" do
    alias TradingSystem.Stocks.USStocks

    @valid_attrs %{name: "some name", symbol: "some symbol"}
    @update_attrs %{name: "some updated name", symbol: "some updated symbol"}
    @invalid_attrs %{name: nil, symbol: nil}

    def us_stocks_fixture(attrs \\ %{}) do
      {:ok, us_stocks} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Stocks.create_us_stocks()

      us_stocks
    end

    test "list_usstocks/0 returns all usstocks" do
      us_stocks = us_stocks_fixture()
      assert Stocks.list_usstocks() == [us_stocks]
    end

    test "get_us_stocks!/1 returns the us_stocks with given id" do
      us_stocks = us_stocks_fixture()
      assert Stocks.get_us_stocks!(us_stocks.id) == us_stocks
    end

    test "create_us_stocks/1 with valid data creates a us_stocks" do
      assert {:ok, %USStocks{} = us_stocks} = Stocks.create_us_stocks(@valid_attrs)
      assert us_stocks.name == "some name"
      assert us_stocks.symbol == "some symbol"
    end

    test "create_us_stocks/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stocks.create_us_stocks(@invalid_attrs)
    end

    test "update_us_stocks/2 with valid data updates the us_stocks" do
      us_stocks = us_stocks_fixture()
      assert {:ok, us_stocks} = Stocks.update_us_stocks(us_stocks, @update_attrs)
      assert %USStocks{} = us_stocks
      assert us_stocks.name == "some updated name"
      assert us_stocks.symbol == "some updated symbol"
    end

    test "update_us_stocks/2 with invalid data returns error changeset" do
      us_stocks = us_stocks_fixture()
      assert {:error, %Ecto.Changeset{}} = Stocks.update_us_stocks(us_stocks, @invalid_attrs)
      assert us_stocks == Stocks.get_us_stocks!(us_stocks.id)
    end

    test "delete_us_stocks/1 deletes the us_stocks" do
      us_stocks = us_stocks_fixture()
      assert {:ok, %USStocks{}} = Stocks.delete_us_stocks(us_stocks)
      assert_raise Ecto.NoResultsError, fn -> Stocks.get_us_stocks!(us_stocks.id) end
    end

    test "change_us_stocks/1 returns a us_stocks changeset" do
      us_stocks = us_stocks_fixture()
      assert %Ecto.Changeset{} = Stocks.change_us_stocks(us_stocks)
    end
  end
end
