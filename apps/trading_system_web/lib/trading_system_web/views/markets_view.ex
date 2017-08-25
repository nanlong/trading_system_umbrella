defmodule TradingSystem.Web.MarketsView do
  use TradingSystem.Web, :view

  def panel(conn) do
    [
      {"沪深", "cn", ""},
      {"港股", "HKStocksController", market_hk_stocks_path(conn, :index)},
      {"美股", "USStocksController", market_us_stocks_path(conn, :index)},
      {"国内期货", "if", ""},
      {"外盘期货", "gf", ""},
    ]
  end

  def controller_module(conn) do
    Phoenix.Controller.controller_module(conn)
    |> to_string()
    |> String.split(".")
    |> List.last()
  end
end
