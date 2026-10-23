defmodule WardrikProtocol do
  @moduledoc """
  The JSON Schemas of what Wardrik sends and takes: each event, as a CloudEvent.

  Each schema is a file in `priv/v1`, with the `$id` `urn:wardrik:schema:v1:<file name>`:

    * `<noun>.<verb>.json` is the `data` of the CloudEvent of type `wardrik.<noun>.<verb>`
    * `cloudevent.json` is the envelope every event travels in
    * `defs.json` holds the types they share, under `$defs`

  `schema/1` returns one whole, with every `$ref` put in its place, so a validator needs no
  resolver:

      root = JSV.build!(WardrikProtocol.schema("run.started"))
      {:ok, _data} = JSV.validate(event["data"], root)

  An event marked `x-wardrik-live` is sent as it happens and never kept, like `message.delta`.

  Reach for this when you produce or check Wardrik's events, or generate a client for them.
  """

  alias WardrikProtocol.Inline

  @dir Application.app_dir(:wardrik_protocol, "priv/v1")
  @files @dir |> Path.join("*.json") |> Path.wildcard() |> Enum.sort()
  @names Enum.map(@files, &Path.basename(&1, ".json"))
  @events Enum.filter(@names, &String.contains?(&1, "."))

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

  @doc false
  def __mix_recompile__?,
    do: @dir |> Path.join("*.json") |> Path.wildcard() |> Enum.sort() != @files
end
