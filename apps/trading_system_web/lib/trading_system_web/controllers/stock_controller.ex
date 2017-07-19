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
end
