# Changelog

## Unreleased

- `provider_input`, `provider` and `providers`: OAuth apps people sign in with, each held by an
  owner and kept from config or at runtime, its client secret only ever named.
- `owner` and `source` in `defs`, for every resource held at runtime.
- An MCP server's browser sign-in can name an OAuth app as `provider`, and send
  `authorization_params`.
- `Wardrik.Provider`.
- `Wardrik.Owners`, moved from `wardrik`: parses an owner, and the chain its settings resolve
  along, for every package that keeps settings by owner.
- `providers.list`, `providers.add` and `providers.remove`, and `Wardrik.Providers`: an owner's
  OAuth apps, listed with those it gets from further out.
- `Wardrik.AgentID.parse/1` reads an agent's owner with `Wardrik.Owners.parse/1`, so an ID like
  `ac@me/triage` or `acme/@jon` is `:error`.
- `wardrik.provider.added` and `wardrik.provider.removed`.
- `server_input` says an app's client secret is read each time it's needed, not sealed as the
  server is added.

## 0.1.0-rc.1 (2026-10-30)

- Wardrik's events as CloudEvents: a JSON Schema for each event type, and for the envelope.
- Every operation in one OpenAPI 3.1 document, by its `operationId`, with the action it needs, its
  effect and what it acts on.
- `WardrikProtocol.schema/1`, a schema with every `$ref` inlined, for any JSON Schema validator.
- `operations/0` and `operation/1`, each operation with one `input` schema across its path, query
  and body.
- `types/0` and `dataschema/1`, for every event type.
- Live events, like `message.delta`, marked `x-wardrik-live`: sent as they happen, never stored.
- The typed Elixir functions, like `Wardrik.Agent.ask/3`, that packages built on Wardrik call.
- `Wardrik.Server`, the behaviour for what runs Wardrik's operations.
