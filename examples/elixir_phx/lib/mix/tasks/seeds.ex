defmodule Mix.Tasks.Seeds do
  @moduledoc """
  Run database seeds without starting the Phoenix web server.

  Usage:
    mix seeds
  """
  use Mix.Task

  @shortdoc "Run database seeds"

  def run(_) do
    # Start only the necessary applications, excluding the web server
    Mix.Task.run("app.config")

    # Start Ecto and related dependencies
    {:ok, _} = Application.ensure_all_started(:ecto_sql)

    # Start the Repo
    {:ok, _} = ElixirPhx.Repo.start_link()

    # Load and run the seeds file
    seeds_file = "priv/repo/seeds.exs"

    if File.exists?(seeds_file) do
      Code.eval_file(seeds_file)
    else
      Mix.shell().error("Seeds file not found: #{seeds_file}")
    end
  end
end
