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

config :exq,
  name: Exq,
  host: "127.0.0.1",
  port: 6379,
  namespace: "exq",
  concurrency: 100,
  queues: ["default", "queue"],
  poll_timeout: 50,
  scheduler_poll_timeout: 200,
  scheduler_enable: true,
  max_retries: 25,
  shutdown_timeout: 5000

config :exq_ui,
  server: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
