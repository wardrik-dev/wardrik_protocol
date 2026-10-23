defmodule WardrikProtocol.Operations do
  @moduledoc false

  alias WardrikProtocol.Inline

  @methods ~w(get put post patch delete)

  @spec document(Path.t()) :: map()
  def document(dir), do: dir |> Inline.read("openapi") |> Inline.whole(dir)

  @spec build(map()) :: [map()]
  def build(document) do
    for {path, item} <- document["paths"],
        {method, operation} <- item,
        method in @methods do
      described(document, path, method, operation)
    end
  end

  defp described(document, path, method, operation) do
    parameters = Enum.map(operation["parameters"] || [], &local(document, &1))
    {status, response} = success(document, operation["responses"])

    %{
      id: operation["operationId"],
      summary: operation["summary"],
      description: operation["description"],
      method: method,
      path: path,
      action: operation["x-wardrik-action"],
      effect: operation["x-wardrik-effect"],
      subject: operation["x-wardrik-subject"],
      parameters: Enum.map(parameters, &%{name: &1["name"], in: &1["in"]}),
      input: input(parameters, request(operation)),
      status: status,
      output: get_in(response, ["content", "application/json", "schema"]),
      stream: Map.has_key?(response["content"] || %{}, "text/event-stream")
    }
  end

  defp success(document, responses) do
    {status, response} = Enum.find(responses, fn {status, _response} -> status < "300" end)
    {String.to_integer(status), local(document, response)}
  end

  defp request(%{
         "requestBody" => %{"content" => %{"application/json" => %{"schema" => schema}}}
       }),
       do: schema

  defp request(_operation), do: %{"type" => "object", "additionalProperties" => false}

  defp input(parameters, body) do
    Enum.reduce(parameters, body, fn parameter, input ->
      schema = Map.put(parameter["schema"], "description", parameter["description"])

      input
      |> Map.update(
        "properties",
        %{parameter["name"] => schema},
        &Map.put(&1, parameter["name"], schema)
      )
      |> required(parameter)
    end)
  end

  defp required(input, %{"required" => true, "name" => name}),
    do: Map.update(input, "required", [name], &[name | &1])

  defp required(input, _parameter), do: input

  defp local(document, %{"$ref" => "#/" <> pointer}),
    do: get_in(document, String.split(pointer, "/"))

  defp local(_document, value), do: value
end
