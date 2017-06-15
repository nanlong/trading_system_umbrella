defmodule TradingSystem.Web.PageController do
  use TradingSystem.Web, :controller
  alias TradingKernel
  alias Decimal, as: D

  def index(conn, _params) do
    # status = %{
    #   account: 100000,
    #   max_position: 4,
    #   cur_position: 1,
    #   avg_price: 380.00,
    #   n: 10.2
    # }

    # stock = %{
    #   symbol: "TSLA",
    #   date: "2017-06-15",
    #   price: D.new(386.100),
    #   highest_price: D.new(386.250),
    #   lowest_price: D.new(382.310),
    #   pre_close_price: D.new(380.660)
    # }

    # TradingKernel.turtle(status, stock)

    # IO.inspect resp
    
    render conn, "index.html"
  end
end
