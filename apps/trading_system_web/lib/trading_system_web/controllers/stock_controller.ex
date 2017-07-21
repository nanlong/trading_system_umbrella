defmodule TradingSystem.Web.StockController do
  use TradingSystem.Web, :controller

  alias TradingSystem.Stocks


  def index(conn, _params) do
    conn
    |> assign(:title, "股票列表")
    |> render(:index)
  end

  def show(conn, %{"symbol" => symbol}) do
    stock = Stocks.get_stock!(symbol)
    state = Stocks.get_last_stock_state(symbol)
    account = 100000
 
    conn
    |> assign(:title, stock.cname)
    |> assign(:account, account)
    |> assign(:stock, stock)
    |> assign(:state, state)
    |> render(:show)
  end

  def counter(conn, _params) do
    conn
    |> assign(:title, "计算器")
    |> assign(:account, nil)
    |> assign(:buy_signal, nil)
    |> assign(:atr, nil)
    |> render(:counter)
  end

  def post_counter(conn, %{"account" => account, "buy" => buy, "atr" => atr}) do
    buy_signal = Decimal.new(buy)
    atr = Decimal.new(atr)

    conn
    |> assign(:title, "计算器")
    |> assign(:account, String.to_integer(account))
    |> assign(:buy_signal, buy_signal)
    |> assign(:atr, atr)
    |> render(:counter)
  end
end
