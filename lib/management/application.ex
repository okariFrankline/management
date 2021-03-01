defmodule Management.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Management.Repo,
      # Start the Telemetry supervisor
      ManagementWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Management.PubSub},
      # Start the Endpoint (http/https)
      ManagementWeb.Endpoint
      # Start a worker by calling: Management.Worker.start_link(arg)
      # {Management.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Management.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ManagementWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
