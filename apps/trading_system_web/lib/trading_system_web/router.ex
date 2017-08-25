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
    plug TradingSystem.Web.Guardian.CurrentUser
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

    get "/password_reset", PasswordResetController, :new
    post "/password_reset", PasswordResetController, :create
    put "/password_reset", PasswordResetController, :update

    get "/settings", SettingController, :index
    resources "/settings/:page", SettingController, only: [:show, :update], singleton: true

    resources "/markets", MarketController, singleton: true, only: [:show] do
      resources "/CN_Stocks", CNStocksController, param: "symbol", only: [:index, :show]
      resources "/HK_Stocks", HKStocksController, param: "symbol", only: [:index, :show]
      resources "/US_Stocks", USStocksController, param: "symbol", only: [:index, :show]
    end

    resources "/toolbox/calculator", CalculatorController, singleton: true, only: [:show, :create]
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
