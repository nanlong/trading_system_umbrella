defmodule TradingSystem.StocksTest do
  use TradingSystem.DataCase

  alias TradingSystem.Stocks

  describe "stock" do
    alias TradingSystem.Stocks.Stock
    alias Decimal, as: D

    @valid_attrs %{symbol: "AAPL", name: "Apple Inc.", cname: "苹果公司"}
    @invalid_attrs %{symbol: "", name: "", cname: ""}

    def stock_fixture(attrs \\ %{}) do
      {:ok, stock} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Stocks.create_stock()

      stock
    end

    test "list_stocks/0 returns all stock" do
      stock = stock_fixture()
      assert Stocks.list_stock() == [stock]
    end

    test "get_stock!/1 returns the us_stocks with given id" do
      stock = stock_fixture()
      assert Stocks.get_stock!(@valid_attrs) == stock
    end

    test "create_stock/1 with valid data creates a stock" do
      assert {:ok, %Stock{} = stock} = Stocks.create_stock(@valid_attrs)
      assert stock.symbol == "AAPL"
      assert stock.name == "Apple Inc."
      assert stock.cname == "苹果公司"
    end

    test "create_stock/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stocks.create_stock(@invalid_attrs)
    end
  end

  describe "stock_dailyk" do
    alias TradingSystem.Stocks.StockDailyK
    alias Decimal, as: D

    @valid_attrs %{close: "120.5", date: ~D[2010-04-17], highest: "120.5", lowest: "120.5", open: "120.5", symbol: "some symbol", volume: 42, pre_close: "120.8"}
    @invalid_attrs %{close: "", date: ~D[2011-05-18], highest: "", lowest: "", open: "", symbol: "", turnover_vol: ""}

    def stock_dailyk_fixture(attrs \\ %{}) do
      {:ok, stock_dailyk} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Stocks.create_stock_dailyk()

      stock_dailyk
    end

    test "list_stock_dailyk/0 returns all stock_dailyk" do
      stock_dailyk = stock_dailyk_fixture()
      assert Stocks.list_stock_dailyk() == [stock_dailyk]
    end

    test "get_last_stockdailyk/1 with symbol" do
      stock_dailyk = stock_dailyk_fixture()
      assert Stocks.get_last_stock_dailyk("some symbol") == stock_dailyk
    end
    test "create_us_stock_dailys/1 with valid data creates a us_stock_dailys" do
      assert {:ok, %StockDailyK{} = stock_dailyk} = Stocks.create_stock_dailyk(@valid_attrs)
      assert stock_dailyk.close == D.new("120.5")
      assert stock_dailyk.date == ~D[2010-04-17]
      assert stock_dailyk.highest == D.new("120.5")
      assert stock_dailyk.lowest == D.new("120.5")
      assert stock_dailyk.open == D.new("120.5")
      assert stock_dailyk.symbol == "some symbol"
      assert stock_dailyk.volume == D.new(42)
      assert stock_dailyk.pre_close == D.new("120.8")
    end

    test "create_us_stock_dailys/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stocks.create_stock_dailyk(@invalid_attrs)
    end
  end

  describe "stock_5mink" do
    alias TradingSystem.Stocks.Stock5MinK
    alias Decimal, as: D

    @valid_attrs %{close: "120.5", datetime: ~N[2010-04-17 14:00:00.000000], highest: "120.5", lowest: "120.5", open: "120.5", symbol: "some symbol", volume: 42}
    @invalid_attrs %{close: "", datetime: ~N[2010-04-17 14:00:00.000000], highest: "", lowest: "", open: "", symbol: "", volume: ""}

    def stock_5mink_fixture(attrs \\ %{}) do
      {:ok, stock_5mink} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Stocks.create_stock_5mink()

      stock_5mink
    end

    test "list_stock_5mink/0 returns all stock_5mink" do
      stock_5mink = stock_5mink_fixture()
      assert Stocks.list_stock_5mink() == [stock_5mink]
    end

    test "get_stock_5mink?/1 returns the us_stock5_min_k with given id" do
      stock_5mink_fixture()
      assert Stocks.get_stock_5mink?(@valid_attrs)
    end

    test "get_last_stock_5mink/1 returns the us_stock5_min_k with given symbol" do
      item = stock_5mink_fixture()
      assert Stocks.get_last_stock_5mink("some symbol") == item
    end

    test "create_stock_5mink/1 with valid data creates a stock_5mink" do
      assert {:ok, %Stock5MinK{} = stock_5mink} = Stocks.create_stock_5mink(@valid_attrs)
      assert stock_5mink.close == D.new(120.5)
      assert stock_5mink.datetime == ~N[2010-04-17 14:00:00.000000]
      assert stock_5mink.highest == D.new(120.5)
      assert stock_5mink.lowest == D.new(120.5)
      assert stock_5mink.open == D.new(120.5)
      assert stock_5mink.symbol == "some symbol"
      assert stock_5mink.volume == D.new(42)
    end

    test "create_stock_5mink/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stocks.create_stock_5mink(@invalid_attrs)
    end
  end
end
