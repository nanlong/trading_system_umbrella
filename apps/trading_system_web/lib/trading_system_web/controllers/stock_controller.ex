defmodule TradingSystem.Web.StockController do
  use TradingSystem.Web, :controller

  alias TradingSystem.Stocks

  def index(conn, _params) do
    date = Stocks.get_usstock_status_last_date()
    data = Stocks.list_usstock_status(date)
    
    conn
    |> assign(:date, date)
    |> assign(:data, data)
    |> render(:index)
  end

  def show(conn, %{"symbol" => symbol}) do
    stock = Stocks.get_usstock!(symbol)
    status = Stocks.get_last_usstock_status(symbol)

    conn
    |> assign(:stock, stock)
    |> assign(:status, status)
    |> render(:show)
  end
end