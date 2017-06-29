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

    test "get_last_usstockdailyk/1 with symbol" do
      usstock = us_stock_daily_prices_fixture()
      assert Stocks.get_last_usstockdailyk("some symbol") == usstock
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

  describe "usstock" do
    alias TradingSystem.Stocks.USStock

    @valid_attrs %{name: "22nd Century Group, Inc", symbol: "XXII"}
    @invalid_attrs %{name: nil, symbol: nil}

    def usstock_fixture(attrs \\ %{}) do
      {:ok, usstock} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Stocks.create_usstock()

      usstock
    end

    test "list_usstocks/0 returns all usstock" do
      usstock = usstock_fixture()
      assert Stocks.list_usstocks() == [usstock]
    end

    test "count_usstocks/0 returns number" do
      usstock_fixture()
      assert Stocks.count_usstocks() == 1
    end

    test "get_usstock!/1 returns the us_stocks with given id" do
      usstock = usstock_fixture()
      assert Stocks.get_usstock!(@valid_attrs) == usstock
    end

    test "create_usstock/1 with valid data creates a usstock" do
      assert {:ok, %USStock{} = usstock} = Stocks.create_usstock(@valid_attrs)
      assert usstock.name == "22nd Century Group, Inc"
      assert usstock.symbol == "XXII"
    end

    test "create_usstock/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stocks.create_usstock(@invalid_attrs)
    end
  end

  describe "usstock_5mink" do
    alias TradingSystem.Stocks.USStock5MinK

    @valid_attrs %{close_price: "120.5", datetime: ~N[2010-04-17 14:00:00.000000], highest_price: "120.5", lowest_price: "120.5", open_price: "120.5", symbol: "some symbol", volume: 42}
    @update_attrs %{close_price: "456.7", datetime: ~N[2011-05-18 15:01:01.000000], highest_price: "456.7", lowest_price: "456.7", open_price: "456.7", symbol: "some updated symbol", volume: 43}
    @invalid_attrs %{close_price: nil, datetime: nil, highest_price: nil, lowest_price: nil, open_price: nil, symbol: nil, volume: nil}

    def us_stock5_min_k_fixture(attrs \\ %{}) do
      {:ok, us_stock5_min_k} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Stocks.create_us_stock5_min_k()

      us_stock5_min_k
    end

    test "list_usstock_5mink/0 returns all usstock_5mink" do
      us_stock5_min_k = us_stock5_min_k_fixture()
      assert Stocks.list_usstock_5mink() == [us_stock5_min_k]
    end

    test "get_us_stock5_min_k!/1 returns the us_stock5_min_k with given id" do
      us_stock5_min_k = us_stock5_min_k_fixture()
      assert Stocks.get_us_stock5_min_k!(us_stock5_min_k.id) == us_stock5_min_k
    end

    test "create_us_stock5_min_k/1 with valid data creates a us_stock5_min_k" do
      assert {:ok, %USStock5MinK{} = us_stock5_min_k} = Stocks.create_us_stock5_min_k(@valid_attrs)
      assert us_stock5_min_k.close_price == 120.5
      assert us_stock5_min_k.datetime == ~N[2010-04-17 14:00:00.000000]
      assert us_stock5_min_k.highest_price == 120.5
      assert us_stock5_min_k.lowest_price == 120.5
      assert us_stock5_min_k.open_price == 120.5
      assert us_stock5_min_k.symbol == "some symbol"
      assert us_stock5_min_k.volume == 42
    end

    test "create_us_stock5_min_k/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stocks.create_us_stock5_min_k(@invalid_attrs)
    end

    test "update_us_stock5_min_k/2 with valid data updates the us_stock5_min_k" do
      us_stock5_min_k = us_stock5_min_k_fixture()
      assert {:ok, us_stock5_min_k} = Stocks.update_us_stock5_min_k(us_stock5_min_k, @update_attrs)
      assert %USStock5MinK{} = us_stock5_min_k
      assert us_stock5_min_k.close_price == 456.7
      assert us_stock5_min_k.datetime == ~N[2011-05-18 15:01:01.000000]
      assert us_stock5_min_k.highest_price == 456.7
      assert us_stock5_min_k.lowest_price == 456.7
      assert us_stock5_min_k.open_price == 456.7
      assert us_stock5_min_k.symbol == "some updated symbol"
      assert us_stock5_min_k.volume == 43
    end

    test "update_us_stock5_min_k/2 with invalid data returns error changeset" do
      us_stock5_min_k = us_stock5_min_k_fixture()
      assert {:error, %Ecto.Changeset{}} = Stocks.update_us_stock5_min_k(us_stock5_min_k, @invalid_attrs)
      assert us_stock5_min_k == Stocks.get_us_stock5_min_k!(us_stock5_min_k.id)
    end

    test "delete_us_stock5_min_k/1 deletes the us_stock5_min_k" do
      us_stock5_min_k = us_stock5_min_k_fixture()
      assert {:ok, %USStock5MinK{}} = Stocks.delete_us_stock5_min_k(us_stock5_min_k)
      assert_raise Ecto.NoResultsError, fn -> Stocks.get_us_stock5_min_k!(us_stock5_min_k.id) end
    end

    test "change_us_stock5_min_k/1 returns a us_stock5_min_k changeset" do
      us_stock5_min_k = us_stock5_min_k_fixture()
      assert %Ecto.Changeset{} = Stocks.change_us_stock5_min_k(us_stock5_min_k)
    end
  end
end
