defmodule WiktiScraperV2.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      WiktiScraperV2.Repo,
      # Start the Telemetry supervisor
      WiktiScraperV2Web.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: WiktiScraperV2.PubSub},
      # Start the Endpoint (http/https)
      WiktiScraperV2Web.Endpoint
      # Start a worker by calling: WiktiScraperV2.Worker.start_link(arg)
      # {WiktiScraperV2.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WiktiScraperV2.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    WiktiScraperV2Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
