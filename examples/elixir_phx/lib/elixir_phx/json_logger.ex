defmodule ElixirPhx.JsonLogger do
  @moduledoc """
  Simple JSON formatter wrapper for LoggerFileBackend compatibility.
  """

  def format(level, message, timestamp, metadata) do
    log_entry = %{
      "severity" => to_string(level),
      "message" => IO.chardata_to_string(message),
      "time" => format_timestamp(timestamp),
      "metadata" => format_metadata(metadata)
    }

    JSON.encode!(log_entry) <> "\n"
  end

  defp format_timestamp({{year, month, day}, {hour, minute, second, microsecond}}) do
    # Convert to DateTime and format as ISO8601
    {:ok, datetime} =
      DateTime.new(Date.new!(year, month, day), Time.new!(hour, minute, second, microsecond))

    DateTime.to_iso8601(datetime)
  end

  defp format_metadata(metadata) when is_list(metadata) do
    metadata
    |> Enum.filter(fn {_key, value} -> json_serializable?(value) end)
    |> Enum.into(%{})
  end

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
