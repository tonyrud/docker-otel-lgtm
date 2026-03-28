defmodule ElixirPhxWeb.DiceController do
  use ElixirPhxWeb, :controller
  require OpenTelemetry.Tracer, as: Tracer
  require OpenTelemetry.Ctx, as: Ctx

  require Logger

  def roll(_conn, %{"sides" => "timeout"}) do
    Logger.error("Request is going to timeout, simulating a long-running operation")
    Process.sleep(15_000)

    raise "Simulated timeout error"
  end

  def roll(conn, %{"sides" => sides}) do
    start_time = System.monotonic_time()
    sides_int = String.to_integer(sides)

    # Add custom span with attributes
    Tracer.with_span "roll/2" do
      Tracer.set_attributes([
        {"dice.sides", sides_int},
        {"dice.type", "custom"}
      ])

      result = roll_dice(sides_int)

      Logger.debug("Got result: #{result}")

      # Extract OpenTelemetry correlation data (for potential exemplar use)
      trace_correlation = get_trace_correlation()
      Logger.debug("Trace context: #{trace_correlation.trace_id}/#{trace_correlation.span_id}")

      # Emit telemetry events for metrics (without trace_id tags for low cardinality)
      result_range =
        cond do
          result <= sides_int / 3 -> "low"
          result <= sides_int * 2 / 3 -> "medium"
          true -> "high"
        end

      :telemetry.execute([:dice, :rolls], %{total: 1}, %{
        sides: sides_int,
        result_range: result_range
      })

      # For distribution metrics, use 'value' as the measurement key
      :telemetry.execute([:dice, :roll_value], %{value: result}, %{
        sides: sides_int
      })

      # Also emit production-friendly metrics without trace correlation
      :telemetry.execute([:dice, :rolls], %{simple: 1}, %{
        sides: sides_int,
        result_range: result_range
      })

      # fast but random sleep to create some latency and variability in traces

      sleep_time =
        if result > 20 do
          Logger.warning("Rolling a dice with more than 20 sides may take longer to process")

          # 1s to 10s sleep to create some high-latency traces for larger dice
          Enum.take_every(1000..10000, 1000) |> Enum.random()
        else
          Enum.take_every(10..100, 10) |> Enum.random()
        end

      Tracer.set_attribute("process.sleep", sleep_time)

      # Simulate some processing time
      Process.sleep(sleep_time)

      # Emit processing time telemetry
      end_time = System.monotonic_time()
      duration = System.convert_time_unit(end_time - start_time, :native, :millisecond)

      :telemetry.execute([:dice, :processing_time], %{value: duration}, %{
        sides: sides_int
      })

      # Also emit production-friendly processing time metric
      :telemetry.execute([:dice, :processing_time], %{simple: duration}, %{
        sides: sides_int
      })

      conn
      |> put_status(:ok)
      |> json(%{result: result, sides: sides_int, sleep_time: sleep_time})
    end
  end

  defp roll_dice(sides) when sides > 0 and sides <= 100 do
    # Logger.metadata( ) has trace and span ids in the metadata, so they will be included in all logs
    Logger.info("Rolling a #{sides}-sided dice")

    Tracer.with_span "roll_dice/1" do
      Tracer.set_attributes([
        {"dice.sides", sides},
        {"operation.type", "random_generation"}
      ])

      result = Enum.random(1..sides)

      # Add some custom events
      Tracer.add_event("dice.rolled", [
        {"result", result},
        {"timestamp", System.system_time(:millisecond)}
      ])

      result
    end
  end

  # Extract current OpenTelemetry trace and span IDs for metric correlation
  defp get_trace_correlation do
    span_ctx = Tracer.current_span_ctx()

    trace_id =
      case span_ctx do
        {:span_ctx, _trace_id_int, trace_id_hex, _span_id_int, _span_id_hex, _, _, _, _, _, _}
        when is_binary(trace_id_hex) ->
          trace_id_hex

        _ ->
          "no_trace"
      end

    span_id =
      case span_ctx do
        {:span_ctx, _trace_id_int, _trace_id_hex, _span_id_int, span_id_hex, _, _, _, _, _, _}
        when is_binary(span_id_hex) ->
          span_id_hex

        _ ->
          "no_span"
      end

    %{
      trace_id: trace_id,
      span_id: span_id
    }
  end
end
