defmodule TradingSystem.Web.USStocksController do
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
      |> render(:novip)
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
    
    user_config =
      Accounts.get_config(user_id: conn.assigns.current_user.id)
      |> Map.from_struct()
      |> Map.delete(:__meta__)
      |> Map.delete(:id)
      |> Map.delete(:user_id)
      |> Map.delete(:inserted_at)
      |> Map.delete(:updated_at)

    config = %{
      symbol: symbol,
      tread: (if Decimal.cmp(state.ma50, state.ma300) == :gt, do: "bull", else: "bear"),
      isBlacklist: Stocks.blacklist?(symbol),
      isStar: Stocks.star?(symbol),
      isVip: Accounts.vip?(conn.assigns.current_user),
      userConfig: user_config,
    }
    
    conn
    |> assign(:title, stock.cname)
    |> assign(:config, config)
    |> assign(:stock, stock)
    |> assign(:state, state)
    |> render(:show)
  end
end
