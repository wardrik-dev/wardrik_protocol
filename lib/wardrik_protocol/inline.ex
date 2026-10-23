defmodule WardrikProtocol.Inline do
  @moduledoc false

  @prefix "urn:wardrik:schema:v1:"

  @spec schema(Path.t(), String.t()) :: map()
  def schema(dir, name), do: dir |> read(name) |> Map.drop(["$schema", "$id"]) |> whole(dir)

  defp read(dir, name), do: dir |> Path.join(name <> ".json") |> File.read!() |> JSON.decode!()

  defp whole(%{"$ref" => @prefix <> "defs#/$defs/" <> type}, dir),
    do: dir |> read("defs") |> get_in(["$defs", type]) |> whole(dir)

  defp whole(%{} = schema, dir),
    do: Map.new(schema, fn {key, value} -> {key, whole(value, dir)} end)

  defp whole(list, dir) when is_list(list), do: Enum.map(list, &whole(&1, dir))
  defp whole(value, _dir), do: value
end
