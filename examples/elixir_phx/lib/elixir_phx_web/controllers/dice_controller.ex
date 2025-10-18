defmodule ElixirPhxWeb.DiceController do
  use ElixirPhxWeb, :controller

  require Logger

  def roll(conn, %{"sides" => sides}) do
    sides_int = String.to_integer(sides)

    result = roll_dice(sides_int)
    sleep_time = Enum.take_every(100..1500, 100) |> Enum.random()

    # Simulate some processing time
    Process.sleep(sleep_time)

    conn
    |> put_status(:ok)
    |> json(%{result: result, sides: sides_int})
  rescue
    ArgumentError ->
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Invalid sides parameter"})
  end

  def roll(conn, _params) do
    result = roll_dice(6)

    conn
    |> put_status(:ok)
    |> json(%{result: result, sides: 6})
  end

  defp roll_dice(sides) when sides > 0 and sides < 30 do
    Logger.info("Rolling a #{sides}-sided dice")

    result = Enum.random(1..sides)

    result
  end

  defp roll_dice(_), do: raise(ArgumentError, "Sides must be greater than 0")
end
