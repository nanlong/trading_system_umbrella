defmodule TradingSystem.Web.CNStocksController do
  use TradingSystem.Web, :controller

  alias TradingSystem.Accounts
  alias TradingSystem.Markets

  def index(conn, params) do
    params = Map.put(params, "user_id", conn.assigns.current_user.id)

    market =
      case Map.get(params, "tab", "all") do
        "all" -> :cn
        "bull" -> :cn_bull
        "bear" -> :cn_bear
        "star" -> :cn_star
        "blacklist" -> :cn_blacklist
      end

    page = Markets.paginate_stocks(market, params)

    conn
    |> assign(:title, "沪深")
    |> assign(:params, params)
    |> assign(:page, page)
    |> render(:index)
  end

  def show(conn, %{"symbol" => symbol}) do
    stock = Markets.get_stock!(symbol: symbol)
    user_config = Accounts.get_config(user_id: conn.assigns.current_user.id)
    
    config = %{
      symbol: symbol,
      tread: (if Decimal.cmp(stock.state.ma50, stock.state.ma300) == :gt, do: "bull", else: "bear"),
      isBlacklist: Markets.blacklist_stock?(symbol, conn.assigns.current_user.id),
      isStar: Markets.star_stock?(symbol, conn.assigns.current_user.id),
      isVip: Accounts.vip?(conn.assigns.current_user),
      userConfig: Map.put(user_config, :lot_size, stock.lot_size)
    }
    
    conn
    |> assign(:title, stock.cname)
    |> assign(:config, config)
    |> assign(:stock, stock)
    |> assign(:state, stock.state)
    |> render(:show)
  end
end
