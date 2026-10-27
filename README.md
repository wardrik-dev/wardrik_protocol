# WardrikProtocol

What Wardrik sends and takes: its events, as [CloudEvents](https://cloudevents.io), and its
operations, as one [OpenAPI](https://spec.openapis.org/oas/v3.1.0) document.

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
| `openapi.json` | every operation, and where it's served over HTTP |
| any other | what an operation takes or answers, like `ask.json` and `agent_snapshot.json` |

A schema marked `"x-wardrik-live": true` is an event sent as it happens and never kept:
`activity.changed`, `message.delta`, `reasoning.delta`, `subagent.progress` and `tool_call.progress`.

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

## The operations

`openapi.json` defines each operation once. Every surface offers it by its `operationId`, like
`agent.ask`: the HTTP API, the CLI, an agent's tools. It reads with any OpenAPI 3.1 tool, so an SDK
is generated from the same file.

Each operation says what it needs, beside the HTTP route:

| Extension | Says | Like |
| --- | --- | --- |
| `x-wardrik-action` | what the caller must be allowed to do | `agent.ask` |
| `x-wardrik-effect` | whether it reads, changes or destroys | `read`, `change`, `destructive` |
| `x-wardrik-subject` | what it acts on | `agent`, `agents`, `deployment` |

`WardrikProtocol.operations/0` lists them as maps, and `WardrikProtocol.operation/1` finds one.
Each takes one `input` schema, its path and query parameters and its body together, so a surface
that isn't HTTP sees one set of named fields:

```elixir
%{input: input, output: output} = WardrikProtocol.operation("agent.ask")

{:ok, _input} = JSV.validate(%{"agent" => "acme/triage", "content" => "Hi"}, JSV.build!(input))
```

`parameters` says which fields an HTTP request carries in its path or query. The rest is its body.
