defmodule TradingSystem.MarketsTest do
  use TradingSystem.DataCase

  alias TradingSystem.Markets

  
  describe "stocks" do
    alias TradingSystem.Markets.Stocks

    @stocks [
      %{symbol: "ETH", name: "Ethan Allen Interiors Inc", cname: "伊森艾伦室内装饰", market: "NYSE"},
      %{symbol: "SAH", name: "Sonic Automotive Inc Cl A", cname: "索尼克汽车", market: "NYSE"},
      %{symbol: "ITOT", name: "iShares Core S&P Total US Stoc", cname: "iShares Core S&P Total US Stoc", market: "NASDAQ"},
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

    @tag markets_stocks: true
    test "paginate/1" do
      stocks = stocks_fixture()
      assert Markets.paginate_stocks(:us, page: 1).entries == stocks
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
end