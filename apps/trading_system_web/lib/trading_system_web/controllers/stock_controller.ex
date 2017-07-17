defmodule TradingSystem.Web.StockController do
  use TradingSystem.Web, :controller

  alias TradingSystem.Stocks

  alias TradingSystem.Repo
  alias TradingSystem.Stocks.StockState
  import Ecto.Query

  def index(conn, _params) do
    conn
    |> assign(:title, "股票列表")
    |> render(:index)
  end

  def show(conn, %{"symbol" => symbol}) do
    stock = Stocks.get_stock!(symbol)
    state = Stocks.get_last_stock_state(symbol)
    account = 100000

    # 上一个突破点
    break_list_60 =
      StockState
      |> where([s], s.symbol == ^symbol)
      |> select([s], %{price: s.dcu60, start_date: min(s.date), end_date: max(s.date)})
      |> group_by([s], s.dcu60)
      |> order_by([s], desc: max(s.date))
      |> Repo.all()

    break_list_20 =
      StockState
      |> where([s], s.symbol == ^symbol)
      |> select([s], %{price: s.dcu20, start_date: min(s.date), end_date: max(s.date)})
      |> group_by([s], s.dcu20)
      |> order_by([s], desc: max(s.date))
      |> Repo.all()
    
    conn
    |> assign(:title, stock.cname)
    |> assign(:account, account)
    |> assign(:stock, stock)
    |> assign(:state, state)
    |> assign(:break_list_20, break_list_20)
    |> assign(:break_list_60, break_list_60)
    |> render(:show)
  end
end
