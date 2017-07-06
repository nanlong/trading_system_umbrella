defmodule TradingSystem.StocksTest do
  use TradingSystem.DataCase

  alias TradingSystem.Stocks

  describe "usstock" do
    alias TradingSystem.Stocks.USStock
    alias Decimal, as: D

    @valid_attrs %{symbol: "AAPL", name: "Apple Inc.", cname: "苹果公司"}
    @invalid_attrs %{symbol: "", name: "", cname: ""}

    def usstock_fixture(attrs \\ %{}) do
      {:ok, usstock} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Stocks.create_usstock()

      usstock
    end

    test "list_usstocks/0 returns all usstock" do
      usstock = usstock_fixture()
      assert Stocks.list_usstock() == [usstock]
    end

    test "get_usstock!/1 returns the us_stocks with given id" do
      usstock = usstock_fixture()
      assert Stocks.get_usstock!(@valid_attrs) == usstock
    end

    test "create_usstock/1 with valid data creates a usstock" do
      assert {:ok, %USStock{} = usstock} = Stocks.create_usstock(@valid_attrs)
      assert usstock.symbol == "AAPL"
      assert usstock.name == "Apple Inc."
      assert usstock.cname == "苹果公司"
    end

    test "create_usstock/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stocks.create_usstock(@invalid_attrs)
    end
  end

  describe "usstock_dailyk" do
    alias TradingSystem.Stocks.USStockDailyK
    alias Decimal, as: D

    @valid_attrs %{close_price: "120.5", date: ~D[2010-04-17], highest_price: "120.5", lowest_price: "120.5", open_price: "120.5", symbol: "some symbol", volume: 42, pre_close_price: "120.8"}
    @invalid_attrs %{close_price: "", date: ~D[2011-05-18], highest_price: "", lowest_price: "", open_price: "", symbol: "", turnover_vol: ""}

    def usstock_dailyk_fixture(attrs \\ %{}) do
      {:ok, usstock_dailyk} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Stocks.create_usstock_dailyk()

      usstock_dailyk
    end

    test "list_usstock_dailyk/0 returns all usstock_dailyk" do
      usstock_dailyk = usstock_dailyk_fixture()
      assert Stocks.list_usstock_dailyk() == [usstock_dailyk]
    end

    test "get_last_usstockdailyk/1 with symbol" do
      usstock_dailyk = usstock_dailyk_fixture()
      assert Stocks.get_last_usstock_dailyk("some symbol") == usstock_dailyk
    end
    test "create_us_stock_daily_prices/1 with valid data creates a us_stock_daily_prices" do
      assert {:ok, %USStockDailyK{} = usstock_dailyk} = Stocks.create_usstock_dailyk(@valid_attrs)
      assert usstock_dailyk.close_price == D.new("120.5")
      assert usstock_dailyk.date == ~D[2010-04-17]
      assert usstock_dailyk.highest_price == D.new("120.5")
      assert usstock_dailyk.lowest_price == D.new("120.5")
      assert usstock_dailyk.open_price == D.new("120.5")
      assert usstock_dailyk.symbol == "some symbol"
      assert usstock_dailyk.volume == D.new(42)
      assert usstock_dailyk.pre_close_price == D.new("120.8")
    end

    test "create_us_stock_daily_prices/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stocks.create_usstock_dailyk(@invalid_attrs)
    end
  end

  describe "usstock_5mink" do
    alias TradingSystem.Stocks.USStock5MinK
    alias Decimal, as: D

    @valid_attrs %{close_price: "120.5", datetime: ~N[2010-04-17 14:00:00.000000], highest_price: "120.5", lowest_price: "120.5", open_price: "120.5", symbol: "some symbol", volume: 42}
    @invalid_attrs %{close_price: "", datetime: ~N[2010-04-17 14:00:00.000000], highest_price: "", lowest_price: "", open_price: "", symbol: "", volume: ""}

    def usstock_5mink_fixture(attrs \\ %{}) do
      {:ok, usstock_5mink} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Stocks.create_usstock_5mink()

      usstock_5mink
    end

    test "list_usstock_5mink/0 returns all usstock_5mink" do
      usstock_5mink = usstock_5mink_fixture()
      assert Stocks.list_usstock_5mink() == [usstock_5mink]
    end

    test "get_usstock_5mink?/1 returns the us_stock5_min_k with given id" do
      usstock_5mink_fixture()
      assert Stocks.get_usstock_5mink?(@valid_attrs)
    end

    test "get_last_usstock_5mink/1 returns the us_stock5_min_k with given symbol" do
      item = usstock_5mink_fixture()
      assert Stocks.get_last_usstock_5mink("some symbol") == item
    end

    test "create_usstock_5mink/1 with valid data creates a usstock_5mink" do
      assert {:ok, %USStock5MinK{} = usstock_5mink} = Stocks.create_usstock_5mink(@valid_attrs)
      assert usstock_5mink.close_price == D.new(120.5)
      assert usstock_5mink.datetime == ~N[2010-04-17 14:00:00.000000]
      assert usstock_5mink.highest_price == D.new(120.5)
      assert usstock_5mink.lowest_price == D.new(120.5)
      assert usstock_5mink.open_price == D.new(120.5)
      assert usstock_5mink.symbol == "some symbol"
      assert usstock_5mink.volume == D.new(42)
    end

    test "create_usstock_5mink/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stocks.create_usstock_5mink(@invalid_attrs)
    end
  end
end
