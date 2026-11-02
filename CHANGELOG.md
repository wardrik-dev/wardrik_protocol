# Changelog

## 0.1.0-rc.2 (2026-10-31)

- `Wardrik.Owners`: parses an owner, and gives the chain its settings resolve along, nearest
  first, for every package that keeps settings by owner.
- OAuth apps people sign in with: `providers.list`, `providers.add` and `providers.remove`,
  `Wardrik.Providers` and `Wardrik.Provider`, the schemas `provider_input`, `provider` and
  `providers`, and the events `wardrik.provider.added` and `wardrik.provider.removed`.
- Webhooks an org or person adds for their agents' notices: `notify_targets.list`,
  `notify_targets.add` and `notify_targets.remove`, `Wardrik.NotifyTargets` and
  `Wardrik.NotifyTarget`, the schemas `notify_target_input`, `notify_target` and
  `notify_targets`, and the events `wardrik.notify_target.added` and
  `wardrik.notify_target.removed`.
- `provider.read` and `notify_target.read` for `:reader`, `provider.add` and
  `notify_target.add` for `:definer`.
- `providers.list`, `mcp_servers.list` and `notify_targets.list` answer an owner's own and those
  it gets from further out. Each says its `owner` and `source`, in `defs`, and `Wardrik.MCPServer`
  has both. A server the deployment starts as a command has no `url`.
- An MCP server's browser sign-in names an OAuth app as `provider`, or gives its own with
  `authorization_params`.
- Secrets are only ever named: an app's client secret, read each time it's needed, and a notify
  target's.

### Breaking

- Every behaviour's callbacks take a request struct, then their options:
  `Wardrik.Server`'s `run/1` and `stream/1` a `Wardrik.Server.Request`, and `follow/2` a
  `Wardrik.Server.Follow`; `Wardrik.Channel`'s `request/2` the request, then the options, and
  `notify/2` a `Wardrik.Channel.Notification`; `Wardrik.Channel.Installations`' callbacks a
  `Wardrik.Channel.Installations.Request`, or the installation to `put/2`.
- `secret_input` requires a `purpose`, and a secret's `kind` says what it's for.
- `Wardrik.AgentID.parse/1` reads the owner with `Wardrik.Owners.parse/1`, so an ID like
  `ac@me/triage` or `acme/@jon` is `:error`.
- `Wardrik.Scope.new/2` takes the server, then `:wardrik`, `:principal` and `:grants` by name.
  `Wardrik.Resource.owned/2` takes the owner, then `:kind` and `:name`.
- An operation's function with two or more path parameters takes them by name in its input, as
  `Wardrik.Agent.approve(scope, agent: "acme/books", interrupt: "call_1")`: `Wardrik.Agent`'s
  `approve/2`, `deny/2`, `kill/2`, `authorization/2`, `trigger_set/2` and `trigger_remove/2`,
  `Wardrik.Hook.deliver/2` and `deliver_with_secret/2`, and `Wardrik.Channel.deliver/2`.

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
