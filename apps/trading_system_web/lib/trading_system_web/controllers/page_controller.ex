defmodule TradingSystem.Web.PageController do
  use TradingSystem.Web, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
