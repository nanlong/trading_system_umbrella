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

  def scheme(conn, %{"system" => "1"} = params), do: scheme(conn, params |> Map.delete("system") |> Map.put("cycle", 20))
  def scheme(conn, %{"system" => "2"} = params), do: scheme(conn, params |> Map.delete("system") |> Map.put("cycle", 60))

  def scheme(conn, %{"us_stocks_symbol" => symbol, "d" => d, "cycle" => cycle}) do
    stock = Markets.get_stock!(symbol: symbol)
    state = Markets.get_stock_state(symbol: symbol, date: d)
    date_range = 
      Markets.list_stock_state(symbol: symbol)
      |> Enum.map(fn(x) -> Date.to_string(x.date) end)
      |> Enum.reverse()
    user_config = 
      Accounts.get_config(user_id: conn.assigns.current_user.id)
      |> Map.put(:lot_size, stock.lot_size)

    config = %{
      symbol: symbol,
      tread: (if Decimal.cmp(state.ma50, state.ma300) == :gt, do: "bull", else: "bear"),
      isBlacklist: Markets.blacklist_stock?(symbol, conn.assigns.current_user.id),
      isStar: Markets.star_stock?(symbol, conn.assigns.current_user.id),
      isVip: Accounts.vip?(conn.assigns.current_user),
      userConfig: Map.put(user_config, :lot_size, stock.lot_size),
    }

    conn
    |> assign(:date, d)
    |> assign(:system, (if cycle == 20, do: "1", else: "2"))
    |> assign(:stock, stock)
    |> assign(:state, state)
    |> assign(:cycle, cycle)
    |> assign(:config, config)
    |> assign(:user_config, user_config)
    |> assign(:date_range, date_range)
    |> render(:scheme)
  end
end
