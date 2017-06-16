defmodule TradingSystem.Web.PageController do
  use TradingSystem.Web, :controller

  alias TradingSystem.Stocks
  alias TradingKernel.Turtle
  alias Decimal, as: D

  def index(conn, _params) do
    # status = %{
    #   account: 100000,
    #   max_position_size: 4,
    #   position_size: 1,
    #   position: [%{amount: 74, price: 386}],
    #   avg_price: 380.00,
    #   n: 10.2,
    #   trade_type: :long,
    #   turtle_s1: %{
    #     in_point: %{long: 0, short: 0},
    #     out_point: %{long: 0, short: 0},
    #     stop_point: %{long: 0, short: 0},
    #   },
    #   turtle_s2: %{
    #     in_point: %{long: 0, short: 0},
    #     out_point: %{long: 0, short: 0},
    #     stop_point: %{long: 0, short: 0},
    #   }
    # }

    # stock = %{
    #   symbol: "TSLA",
    #   date: "2017-06-15",
    #   price: 386.100,
    #   bid_price: 386,
    #   ask_price: 386,
    #   highest_price: 386.250,
    #   lowest_price: 382.310,
    #   pre_close_price: 380.660
    # }

    # results = Stocks.list_us_stock_daily_prices(stock.symbol, stock.date, 1741) |> Enum.reverse

    # resp = Turtle.system(:one, status, stock, results)

    # IO.inspect resp
    
    render conn, "index.html"
  end
end
