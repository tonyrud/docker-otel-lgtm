defmodule ElixirPhxWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000},
      # Add Prometheus metrics reporter
      {TelemetryMetricsPrometheus, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics (using counter and distribution instead of summary)
      counter("phoenix.endpoint.start.count"),
      distribution("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond},
        reporter_options: [
          buckets: [10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000]
        ]
      ),
      distribution("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond},
        reporter_options: [
          buckets: [10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000]
        ]
      ),

      # Database Metrics (using distribution instead of summary)
      distribution("elixir_phx.repo.query.total_time",
        unit: {:native, :millisecond},
        description: "The sum of the other measurements",
        reporter_options: [
          buckets: [1, 5, 10, 25, 50, 100, 250, 500, 1000, 2500]
        ]
      ),
      distribution("elixir_phx.repo.query.query_time",
        unit: {:native, :millisecond},
        description: "The time spent executing the query",
        reporter_options: [
          buckets: [1, 5, 10, 25, 50, 100, 250, 500, 1000, 2500]
        ]
      ),

      # VM Metrics (using counter instead of summary where appropriate)
      counter("vm.memory.count"),
      counter("vm.total_run_queue_lengths.count"),

      # Custom Business Metrics
      counter("dice.rolls.total",
        tags: [:sides, :result_range],
        description: "Total number of dice rolls"
      ),
      distribution("dice.roll_value",
        tags: [:sides],
        unit: :unit,
        description: "Distribution of dice roll values",
        reporter_options: [
          buckets: [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000]
        ]
      ),
      distribution("dice.processing_time",
        tags: [:sides],
        unit: {:native, :millisecond},
        description: "Time taken to process dice roll",
        reporter_options: [
          buckets: [10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000]
        ]
      )
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {ElixirPhxWeb, :count_users, []}
      {__MODULE__, :dispatch_vm_metrics, []}
    ]
  end

  def dispatch_vm_metrics do
    :telemetry.execute([:vm, :memory], %{count: 1})

    :telemetry.execute(
      [:vm, :total_run_queue_lengths],
      %{count: 1}
    )
  end
end
