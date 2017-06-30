defmodule TradingSystem.Web.Router do
  use TradingSystem.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TradingSystem.Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/status/:symbol", PageController, :status
  end

  pipeline :exq do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
    plug ExqUi.RouterPlug, namespace: "exq"
  end

  scope "/exq", ExqUi do
    pipe_through :exq
    forward "/", RouterPlug.Router, :index
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
