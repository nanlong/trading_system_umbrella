use Mix.Config

# Configure your database
config :trading_system, TradingSystem.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "trading_system_dev2",
  hostname: "localhost",
  pool_size: 10

config :logger, level: :info