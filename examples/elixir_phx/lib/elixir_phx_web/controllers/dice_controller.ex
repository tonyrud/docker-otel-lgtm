defmodule ElixirPhxWeb.DiceController do
  use ElixirPhxWeb, :controller
  require OpenTelemetry.Tracer, as: Tracer

  require Logger

  def roll(conn, %{"sides" => sides}) do
    sides_int = String.to_integer(sides)

    # Add custom span with attributes
    Tracer.with_span "roll/2" do
      Tracer.set_attributes([
        {"dice.sides", sides_int},
        {"dice.type", "custom"}
      ])

      result = roll_dice(sides_int)

      Logger.debug("Got result: #{result}")

      # fast but random sleep to create some latency and variability in traces

      sleep_time =
        if result > 20 do
          Logger.warn("Rolling a dice with more than 20 sides may take longer to process")

          # 1s to 10s sleep to create some high-latency traces for larger dice
          Enum.take_every(1000..10000, 1000) |> Enum.random()
        else
          Enum.take_every(10..100, 10) |> Enum.random()
        end

      Tracer.set_attribute("process.sleep", sleep_time)

      # Simulate some processing time
      Process.sleep(sleep_time)

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
end
