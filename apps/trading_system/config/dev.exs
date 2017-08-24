use Mix.Config

# Configure your database
config :trading_system, TradingSystem.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "trading_system_dev",
  hostname: "localhost",
  pool_size: 20

config :logger, level: :info