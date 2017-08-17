defmodule TradingSystem.Web.Router do
  use TradingSystem.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug TradingSystem.Web.Plug.CurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug TradingSystem.Graphql.Context
  end

  scope "/", TradingSystem.Web do
    pipe_through [:browser, :browser_session] # Use the default browser stack

    get "/", PageController, :index

    get "/join", UserController, :new
    post "/join", UserController, :create

    get "/login", SessionController, :new
    post "/login", SessionController, :create

    get "/logout", SessionController, :delete

    get "/settings", SettingController, :index
    resources "/settings/:page", SettingController, only: [:show, :update], singleton: true

    resources "/market", MarketController, singleton: true, only: [:show] do
      resources "/US_Stocks", USStocksController, param: "symbol", only: [:index, :show]
    end

    get "/counter", StockController, :new_counter
    post "/counter", StockController, :post_counter
  end

  scope "/api" do
    pipe_through [:graphql]

    forward "/", Absinthe.Plug,
      schema: TradingSystem.Graphql.Schema
  end

  scope "/graphiql" do
    pipe_through [:graphql]

    forward "/", Absinthe.Plug.GraphiQL,
      schema: TradingSystem.Graphql.Schema
  end

  # Other scopes may use custom stacks.
  # scope "/api", TradingSystem.Web do
  #   pipe_through :api
  # end
end
