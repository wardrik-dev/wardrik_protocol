defmodule WardrikProtocol do
  @moduledoc """
  What Wardrik sends and takes: its events, as CloudEvents, and its operations, as OpenAPI.

      root = JSV.build!(WardrikProtocol.schema("run.started"))
      {:ok, _data} = JSV.validate(event["data"], root)

      %{method: "post", path: "/v1/agents/{agent}/messages"} = WardrikProtocol.operation("agent.ask")
  """

  alias WardrikProtocol.Inline
  alias WardrikProtocol.Operations

  @dir Application.app_dir(:wardrik_protocol, "priv/v1")
  @files @dir |> Path.join("*.json") |> Path.wildcard() |> Enum.sort()
  @names @files |> Enum.map(&Path.basename(&1, ".json")) |> List.delete("openapi")
  @events Enum.filter(@names, &String.contains?(&1, "."))
  @document Operations.document(@dir)
  @operations Operations.build(@document)

  @typedoc """
  An operation: its `id`, the `operationId`, where it's served over HTTP, the `action` a caller must
  be allowed, its `effect` (`read`, `change` or `destructive`), its `subject` (`agent`, `agents`,
  `deployment`, `owner` for an org's or a person's accounts and servers, or `hook` for a request
  that proves itself with a secret in place of a caller), one
  `input` schema of its parameters and body together, and its `output` schema.
  """
  @type operation() :: %{
          id: String.t(),
          summary: String.t(),
          description: String.t() | nil,
          method: String.t(),
          path: String.t(),
          action: String.t(),
          effect: String.t(),
          subject: String.t(),
          parameters: [%{name: String.t(), in: String.t()}],
          input: map(),
          status: pos_integer(),
          output: map() | nil,
          stream: boolean()
        }

  for file <- @files, do: @external_resource(file)

  @doc "Returns where the schemas are as files."
  @spec dir() :: Path.t()
  def dir, do: @dir

  @doc "Lists every event's type, like `wardrik.run.started`."
  @spec types() :: [String.t()]
  def types, do: Enum.map(@events, &("wardrik." <> &1))

  @doc "Returns the `dataschema` of an event's type."
  @spec dataschema(String.t()) :: String.t()
  def dataschema("wardrik." <> name) when name in @events, do: "urn:wardrik:schema:v1:" <> name

  @doc "Returns whether events of the type are sent as they happen and never kept."
  @spec live?(String.t()) :: boolean()
  def live?("wardrik." <> name) when name in @events,
    do: Map.get(schema(name), "x-wardrik-live", false)

  @doc "Returns the schema `name` whole, like `run.started`, `cloudevent` or `defs`."
  @spec schema(String.t()) :: map()
  for name <- @names do
    def schema(unquote(name)), do: unquote(Macro.escape(Inline.schema(@dir, name)))
  end

  @doc "Returns the OpenAPI document of every operation, with each schema put in its place."
  @spec openapi() :: map()
  def openapi, do: @document

  @doc "Lists every operation, in the order of its path."
  @spec operations() :: [operation()]
  def operations, do: @operations

  @doc "Returns the operation `id` names, like `agent.ask`, or `nil`."
  @spec operation(String.t()) :: operation() | nil
  for %{id: id} = operation <- @operations do
    def operation(unquote(id)), do: unquote(Macro.escape(operation))
  end

  def operation(_id), do: nil

  @doc false
  def __mix_recompile__?,
    do: @dir |> Path.join("*.json") |> Path.wildcard() |> Enum.sort() != @files
end
