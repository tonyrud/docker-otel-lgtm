defmodule ElixirPhx.JsonLogger do
  @moduledoc """
  Simple JSON formatter wrapper for LoggerFileBackend compatibility.
  """

  def format(level, message, timestamp, metadata) do
    # Create a log entry in the same format as LoggerJSON
    log_entry = %{
      "severity" => to_string(level),
      "message" => IO.chardata_to_string(message),
      "time" => format_timestamp(timestamp),
      "metadata" => format_metadata(metadata)
    }

    JSON.encode!(log_entry) <> "\n"
  end

  defp format_timestamp({{year, month, day}, {hour, minute, second, microsecond}}) do
    # Format as ISO8601
    :io_lib.format(
      "~4..0w-~2..0w-~2..0wT~2..0w:~2..0w:~2..0w.~3..0wZ",
      [year, month, day, hour, minute, second, div(microsecond, 1000)]
    )
    |> IO.chardata_to_string()
  end

  defp format_metadata(metadata) when is_list(metadata) do
    metadata
    |> Enum.filter(fn {_key, value} -> json_serializable?(value) end)
    |> Enum.into(%{})
  end

  defp json_serializable?(value) when is_pid(value), do: false
  defp json_serializable?(value) when is_reference(value), do: false
  defp json_serializable?(value) when is_port(value), do: false
  defp json_serializable?(value) when is_function(value), do: false
  # MFA tuples
  defp json_serializable?({_, _, _}), do: false
  defp json_serializable?(value) when is_atom(value), do: true
  defp json_serializable?(value) when is_binary(value), do: true
  defp json_serializable?(value) when is_number(value), do: true
  defp json_serializable?(value) when is_boolean(value), do: true
  defp json_serializable?(nil), do: true
  defp json_serializable?(value) when is_list(value), do: Enum.all?(value, &json_serializable?/1)

  defp json_serializable?(value) when is_map(value),
    do: Enum.all?(value, fn {k, v} -> json_serializable?(k) and json_serializable?(v) end)

  defp json_serializable?(_), do: false
end
