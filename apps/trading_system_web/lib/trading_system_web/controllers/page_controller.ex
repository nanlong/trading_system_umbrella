defmodule TradingSystem.Web.PageController do
  use TradingSystem.Web, :controller

  alias TradingSystem.Stocks

  def index(conn, _params) do
    stocks = Stocks.list_stock()

    conn
    |> assign(:stocks, stocks)
    |> render(:index)
  end
end
