defmodule TradingSystem.Application do
  @moduledoc """
  The TradingSystem Application Service.

  The trading system business domain lives in this application.

  Exposes API to clients such as the `TradingSystem.Web` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      supervisor(TradingSystem.Repo, []),
    ], strategy: :one_for_one, name: TradingSystem.Supervisor)
  end
end
