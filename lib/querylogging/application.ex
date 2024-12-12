defmodule Querylogging.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      QueryloggingWeb.Telemetry,
      Querylogging.Repo,
      {DNSCluster, query: Application.get_env(:querylogging, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Querylogging.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Querylogging.Finch},
      # Start a worker by calling: Querylogging.Worker.start_link(arg)
      # {Querylogging.Worker, arg},
      # Start to serve requests, typically the last entry
      QueryloggingWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Querylogging.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    QueryloggingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
