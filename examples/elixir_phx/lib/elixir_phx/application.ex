defmodule ElixirPhx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require OpentelemetryPhoenix
  require OpentelemetryEcto

  @impl true
  def start(_type, _args) do
    init_opentelemetry()

    # Run migrations automatically on startup
    migrate()

    children = [
      ElixirPhxWeb.Telemetry,
      ElixirPhx.Repo,
      {DNSCluster, query: Application.get_env(:elixir_phx, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ElixirPhx.PubSub},
      ElixirPhxWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirPhx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp init_opentelemetry do
    OpentelemetryBandit.setup()
    OpentelemetryPhoenix.setup(adapter: :bandit)
    # OpentelemetryLoggerMetadata.setup()
    # TODO: query spans do not have SQL statements
    # Adds extra query spans to every request as well??
    OpentelemetryEcto.setup([:elixir_phx, :repo], db_statement: true)
  end

  defp migrate do
    # Only run migrations if we're in a development or test environment
    if Mix.env() in [:dev, :test] do
      repos = Application.get_env(:elixir_phx, :ecto_repos, [])

      for repo <- repos do
        {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
      end
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixirPhxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
