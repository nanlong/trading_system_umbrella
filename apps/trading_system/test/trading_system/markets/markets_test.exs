defmodule TradingSystem.MarketsTest do
  use TradingSystem.DataCase

  alias TradingSystem.Markets

  
  describe "stocks" do
    alias TradingSystem.Markets.Stocks

    @stocks [
      %{symbol: "ETH", name: "Ethan Allen Interiors Inc", cname: "伊森艾伦室内装饰", market: "NYSE", lot_size: 1},
      %{symbol: "SAH", name: "Sonic Automotive Inc Cl A", cname: "索尼克汽车", market: "NYSE", lot_size: 1},
      %{symbol: "ITOT", name: "iShares Core S&P Total US Stoc", cname: "iShares Core S&P Total US Stoc", market: "NASDAQ", lot_size: 1},
    ]

    def stock_fixture(attrs \\ %{}) do
      valid_data = List.first(@stocks)

      {:ok, stock} =
        attrs
        |> Enum.into(valid_data)
        |> Markets.create_stock()
      
      stock
    end

    def stocks_fixture do
      Enum.map(@stocks, fn attrs -> 
        {:ok, stock} =
          %{}
          |> Enum.into(attrs)
          |> Markets.create_stock()
        
        stock
      end)      
    end

    @tag markets_stocks: true
    test "create_stock/1 with valid data" do
      attrs = List.first(@stocks)
      assert {:ok, %Stocks{} = stock} = Markets.create_stock(attrs)
      assert stock.symbol == "ETH"
      assert stock.name == "Ethan Allen Interiors Inc"
      assert stock.cname == "伊森艾伦室内装饰"
      assert stock.market == "NYSE"
    end

    @tag markets_stocks: true
    test "get_stock/1" do
      stock = stock_fixture()
      assert Markets.get_stock(symbol: stock.symbol) == stock
    end
  end

  describe "stock_state" do
    @valid_data %{date: ~D[2017-08-21], symbol: "ETH"}

    @tag markets_state: true
    test "create_state/1" do
      stock_fixture()
      assert {:ok, %{state: state, stock: stock}} = Markets.create_stock_state(@valid_data)
      assert state.id == stock.stock_state_id
      assert state.symbol == stock.symbol
    end
  end

  describe "futures" do
    alias TradingSystem.Markets.Futures

    @valid_data %{symbol: "RB0", name: "螺纹钢", market: "SHFE"}
    @invalid_attrs %{symbol: nil, name: nil, market: nil}
    @update_attrs %{lot_size: 10}

    def future_fixture(attrs \\ %{}) do
      {:ok, future} =
        attrs
        |> Enum.into(@valid_data)
        |> Markets.create_future()
      
      future
    end

    @tag markets_futures: true
    test "create_future/1 with valid attrs" do
      assert {:ok, %Futures{} = future} = Markets.create_future(@valid_data)
      assert future.symbol == "RB0"
      assert future.name == "螺纹钢"
      assert future.market == "SHFE"
    end

    @tag markets_futures: true
    test "create_future/1 with invalid attrs" do
      assert {:error, %Ecto.Changeset{}} = Markets.create_future(@invalid_attrs)
    end

    @tag markets_futures: true
    test "list/1 get cn market" do
      future = future_fixture()
      assert Markets.list_future(:i) == [future]
    end

    @tag markets_futures: true
    test "update/2" do
      future = future_fixture()
      assert {:ok, %Futures{} = future} = Markets.update_future(future, @update_attrs)
      assert future.lot_size == 10
    end
  end
end