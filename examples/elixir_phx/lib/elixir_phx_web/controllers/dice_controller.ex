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
      sleep_time = Enum.take_every(100..1500, 100) |> Enum.random()

      Tracer.set_attribute("process.sleep", sleep_time)

      Logger.debug("Got result: #{result}")

      # Simulate some processing time
      Process.sleep(sleep_time)

      conn
      |> put_status(:ok)
      |> json(%{result: result, sides: sides_int})
    end
  end

  def roll(conn, _params) do
    result = roll_dice(6)

    conn
    |> put_status(:ok)
    |> json(%{result: result, sides: 6})
  end

  defp roll_dice(sides) when sides > 0 and sides < 30 do
    # Logger.metadata( ) has trace and span ids in the metadata, so they will be included in all logs
    Logger.info("Rolling a #{sides}-sided dice")

    Tracer.with_span "roll_dice/1" do
      Tracer.set_attributes([
        {"dice.sides", sides},
        {"operation.type", "random_generation"}
      ])

      result = Enum.random(1..sides)

      # Simulate a long processing time for high rolls
      if result > 4 do
        Process.sleep(5500)
      end

      # Add some custom events
      Tracer.add_event("dice.rolled", [
        {"result", result},
        {"timestamp", System.system_time(:millisecond)}
      ])

      result
    end
  end
end
