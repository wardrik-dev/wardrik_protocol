# WardrikProtocol

The JSON Schemas of what Wardrik sends and takes: its events, as
[CloudEvents](https://cloudevents.io).

## Install

```elixir
def deps do
  [
    {:wardrik_protocol, "~> 0.1"}
  ]
end
```

It has no runtime dependencies. It's data, and a few functions to read it.

## The schemas

Each schema is a file in `priv/v1`, with the `$id` `urn:wardrik:schema:v1:<file name>`:

| File | What it describes |
| --- | --- |
| `<noun>.<verb>.json` | the `data` of the event `wardrik.<noun>.<verb>`, like `run.started.json` |
| `cloudevent.json` | the envelope every event travels in |
| `defs.json` | the types events share, like `message`, `principal` and `activity` |

A schema marked `"x-wardrik-live": true` is an event sent as it happens and never kept:
`activity.changed`, `message.delta`, `reasoning.delta` and `tool_call.progress`.

## Check an event

`WardrikProtocol.schema/1` returns a schema whole, with every `$ref` put in its place, so any JSON
Schema validator takes it without a resolver. With [JSV](https://hexdocs.pm/jsv):

```elixir
envelope = JSV.build!(WardrikProtocol.schema("cloudevent"))
data = JSV.build!(WardrikProtocol.schema("run.started"))

{:ok, _event} = JSV.validate(event, envelope)
{:ok, _data} = JSV.validate(event["data"], data)
```

`WardrikProtocol.types/0` lists every event's type, and `WardrikProtocol.dataschema/1` gives the
`dataschema` an event of a type carries.
