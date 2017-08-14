defmodule TradingSystem.Web.StockController do
  use TradingSystem.Web, :controller

  alias TradingSystem.Accounts
  alias TradingSystem.Stocks
  alias TradingSystem.Stocks.Counter

  plug Guardian.Plug.EnsureAuthenticated, [handler: TradingSystem.Web.Guardian.ErrorHandler]
  plug :vip when action in [:new_counter, :post_counter]

  def vip(conn, _params) do
    if Accounts.vip?(conn.assigns.current_user) do
      conn
    else
      conn
      |> render(:vip)
      |> halt()
    end
  end

  def index(conn, params) do
    page = Stocks.stocks_paginate(Map.put(params, "user_id", conn.assigns.current_user.id))
    
    conn
    |> assign(:title, "股票列表")
    |> assign(:params, params)
    |> assign(:date, Stocks.get_stock_state_last_date())
    |> assign(:page, page)
    |> render(:index)
  end

  def show(conn, %{"symbol" => symbol}) do
    stock = Stocks.get_stock!(symbol)
    state = Stocks.get_last_stock_state(symbol)
    
    config = %{
      symbol: symbol,
      isBlacklist: Stocks.blacklist?(symbol),
      isStar: Stocks.star?(symbol),
      is_vip: Accounts.vip?(conn.assigns.current_user)
    }

    conn
    |> assign(:title, stock.cname)
    |> assign(:config, config)
    |> assign(:stock, stock)
    |> assign(:state, state)
    |> render(:show)
  end

  def new_counter(conn, _params) do
    attrs =
      conn.assigns.user_config
      |> Map.from_struct()
      |> Map.update!(:account, &(:erlang.float_to_binary(&1, decimals: 2)))
      
    changeset = Counter.changeset(%Counter{}, attrs)

    conn
    |> assign(:title, "计算器")
    |> assign(:changeset, changeset)
    |> render(:counter)
  end

  def post_counter(conn, %{"counter" => conter_params}) do
    changeset = Counter.changeset(%Counter{}, conter_params)
    
    if changeset.valid? do
      {account, _} = Float.parse(changeset.changes.account)

      user_config = 
        changeset.changes
        |> Map.put(:account, account)
        |> Map.put(:create_days, 20)

      state = %{
        atr20: Decimal.new(user_config.atr),
        dcu20: Decimal.new(user_config.buy_price),
        dcl20: Decimal.new(user_config.buy_price),
        ma50: (if user_config.trade == "bull", do: Decimal.new(1), else: Decimal.new(0)),
        ma300: (if user_config.trade == "bull", do: Decimal.new(0), else: Decimal.new(1)),
      }
      
      conn
      |> assign(:title, "计算器")
      |> assign(:state, state)
      |> assign(:user_config, user_config)
      |> assign(:changeset, changeset)
      |> render(:counter)
    else
      changeset = %{changeset | action: :post}

      conn
      |> assign(:title, "计算器")
      |> assign(:changeset, changeset)
      |> render(:counter)
    end
  end

  def star_index(conn, params) do
    page = Stocks.stock_stars_paginate(Map.put(params, "user_id", conn.assigns.current_user.id))
    
    conn
    |> assign(:title, "关注列表")
    |> assign(:params, params)
    |> assign(:page, page)
    |> render(:star_index)
  end
end
