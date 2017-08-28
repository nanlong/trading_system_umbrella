defmodule TradingSystem.Web.USStocksController do
  use TradingSystem.Web, :controller

  alias TradingSystem.Accounts
  alias TradingSystem.Markets

  plug Guardian.Plug.EnsureAuthenticated, [handler: TradingSystem.Web.Guardian.ErrorHandler]
  plug :vip when action in [:new_counter, :post_counter]

  def vip(conn, _params) do
    if Accounts.vip?(conn.assigns.current_user) do
      conn
    else
      conn
      |> render(:novip)
      |> halt()
    end
  end

  def index(conn, params) do
    params = Map.put(params, "user_id", conn.assigns.current_user.id)

    market =
      case Map.get(params, "tab", "all") do
        "all" -> :us
        "bull" -> :us_bull
        "bear" -> :us_bear
        "star" -> :us_star
        "blacklist" -> :us_blacklist
      end

    page = Markets.paginate_stocks(market, params)

    conn
    |> assign(:title, "美股")
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
      userConfig: Map.put(user_config, :lot_size, stock.lot_size),
    }
    
    conn
    |> assign(:title, stock.cname)
    |> assign(:config, config)
    |> assign(:stock, stock)
    |> assign(:state, stock.state)
    |> render(:show)
  end
end
