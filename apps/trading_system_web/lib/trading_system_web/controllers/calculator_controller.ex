defmodule TradingSystem.Web.CalculatorController do
  use TradingSystem.Web, :controller

  alias TradingSystem.Stocks.Counter

  def show(conn, _params) do
    attrs =
    conn.assigns.user_config
    |> Map.from_struct()
    |> Map.update!(:account, &(:erlang.float_to_binary(&1, decimals: 2)))
    
    changeset = Counter.changeset(%Counter{}, attrs)

    conn
    |> assign(:title, "计算器")
    |> assign(:changeset, changeset)
    |> render(:show)
  end

  def create(conn, %{"counter" => conter_params}) do
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
      |> render(:show)
    else
      changeset = %{changeset | action: :post}

      conn
      |> assign(:title, "计算器")
      |> assign(:changeset, changeset)
      |> render(:show)
    end
  end
end
