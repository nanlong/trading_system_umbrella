use Mix.Config

# Configure your database
config :trading_system, TradingSystem.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "trading_system_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
