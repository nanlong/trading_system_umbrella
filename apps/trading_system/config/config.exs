use Mix.Config

config :trading_system, ecto_repos: [TradingSystem.Repo]

import_config "#{Mix.env}.exs"
