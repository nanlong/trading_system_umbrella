defmodule TradingSystem.Web.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(TradingSystem.Web.Endpoint, []),
      # Start your own worker by calling: TradingSystem.Web.Worker.start_link(arg1, arg2, arg3)
      # worker(TradingSystem.Web.Worker, [arg1, arg2, arg3]),
      worker(TradingSystem.Web.Scheduler, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TradingSystem.Web.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TradingSystem.Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
