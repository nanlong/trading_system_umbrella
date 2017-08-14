defmodule TradingSystem.Web.PageController do
  use TradingSystem.Web, :controller

  def index(conn, _params) do
    IO.inspect get_session(conn, :token)
    render(conn, :index)
  end
end
