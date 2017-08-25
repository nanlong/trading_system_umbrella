defmodule TradingSystem.Web.MarketController do
  use TradingSystem.Web, :controller

  def show(conn, _params) do
    redirect(conn, to: market_cn_stocks_path(conn, :index))
  end
end