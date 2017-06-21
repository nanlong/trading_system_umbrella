defmodule TradingSystem.Web.PageController do
  use TradingSystem.Web, :controller

  alias TradingSystem.Stocks
  alias TradingKernel.Turtle

  def index(conn, _params) do
    symbol = "FB"
    today = Date.utc_today |> Date.to_string
    
    history = Stocks.list_us_stock_daily_prices(symbol, today)

    Turtle.init(
      symbol: symbol,
      history: history,
    )

    render conn, "index.html"
  end
end
