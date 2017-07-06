defmodule TradingSystem.Web.PageController do
  use TradingSystem.Web, :controller

  alias TradingSystem.Stocks
  alias TradingKernel.Turtle

  def index(conn, _params) do
    stocks = Stocks.stock_list(:dailyk, 4000)

    conn
    |> assign(:stocks, stocks)
    |> render(:index)
  end

  def status(conn, %{"symbol" => symbol}) do
    today = Date.utc_today |> Date.to_string
    
    history = Stocks.list_us_stock_daily_prices(symbol, today)

    Turtle.init(
      account: 10000,
      symbol: symbol,
      history: history,
    )

    conn
    |> assign(:state, Turtle.state)
    |> render(:status)
  end
end
