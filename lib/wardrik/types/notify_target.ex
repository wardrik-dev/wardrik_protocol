defmodule Wardrik.NotifyTarget do
  @moduledoc """
  A place an owner's agents' notices go. `owner` holds it, and `source` is `:config` for one the
  deployment started with, or `:runtime` for one added since. `kind` names what sends its
  notices, as `"webhook"` or `"room"`; one added at runtime is always a webhook. `url` is a
  webhook's, and `secret` the name of the vault secret that signs a runtime webhook's notices,
  never the secret itself.
  """

  use Wardrik.Type,
    schema: ["notify_target"],
    fields: [
      owner: "owner",
      name: "name",
      source: {"source", [:config, :runtime]},
      kind: "kind",
      url: "url",
      secret: "secret.name"
    ]
end
