defmodule TradingSystem.Web.StockController do
  use TradingSystem.Web, :controller

  alias TradingSystem.Stocks

  def index(conn, _params) do
    date = Stocks.get_usstock_state_last_date()
    data = Stocks.list_usstock_state(date)
    
    conn
    |> assign(:title, "股票列表")
    |> assign(:date, date)
    |> assign(:data, data)
    |> render(:index)
  end

  def show(conn, %{"symbol" => symbol}) do
    stock = Stocks.get_usstock!(symbol)
    status = Stocks.get_last_usstock_state(symbol)
    account = 10000

    conn
    |> assign(:title, stock.cname)
    |> assign(:account, account)
    |> assign(:stock, stock)
    |> assign(:status, status)
    |> render(:show)
  end
end
