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

  scope "/", TradingSystem.Web do
    pipe_through [:browser, :browser_session] # Use the default browser stack

    get "/", PageController, :index

    get "/join", UserController, :new
    post "/join", UserController, :create

    get "/login", SessionController, :new
    post "/login", SessionController, :create

    get "/logout", SessionController, :delete

    resources "/stocks", StockController, param: "symbol", only: [:index, :show]

    get "/counter", StockController, :new_counter
    post "/counter", StockController, :post_counter

    get "/star", StockController, :star_index
  end

  forward "/api", Absinthe.Plug,
    schema: TradingSystem.Graphql.Schema

  forward "/graphiql", Absinthe.Plug.GraphiQL,
    schema: TradingSystem.Graphql.Schema

  # Other scopes may use custom stacks.
  # scope "/api", TradingSystem.Web do
  #   pipe_through :api
  # end
end
