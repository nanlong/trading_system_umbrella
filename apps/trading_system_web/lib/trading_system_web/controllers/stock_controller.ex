defmodule TradingSystem.Web.StockController do
  use TradingSystem.Web, :controller

  alias TradingSystem.Stocks
  alias TradingSystem.Stocks.Counter

  def index(conn, _params) do
    conn
    |> assign(:title, "股票列表")
    |> render(:index)
  end

  def show(conn, %{"symbol" => symbol}) do
    stock = Stocks.get_stock!(symbol)
    state = Stocks.get_last_stock_state(symbol)
    account = 100000
    
    config = %{
      symbol: symbol,
      isBlacklist: Stocks.blacklist?(symbol),
      isStar: Stocks.star?(symbol),
    }

    conn
    |> assign(:title, stock.cname)
    |> assign(:config, config)
    |> assign(:account, account)
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
        dcu20: Decimal.new(user_config.buy_price)
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

  def star_index(conn, _params) do
    conn
    |> assign(:title, "关注列表")
    |> render(:star_index)
  end
end
