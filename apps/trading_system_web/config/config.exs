# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :trading_system_web,
  namespace: TradingSystem.Web,
  ecto_repos: [TradingSystem.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :trading_system_web, TradingSystem.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "EC0KTn6S2JzAJ8c6NfhEi5hY721ebhbOosJ/tJji0Q7jV04OXz4Q0jOniC521/6P",
  render_errors: [view: TradingSystem.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TradingSystem.Web.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :trading_system_web, :generators,
  context_app: :trading_system

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
