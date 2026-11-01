defmodule Wardrik.Secrets do
  @moduledoc """
  Operations on an owner's secrets: sealing one, listing them by name, and removing one.

      Wardrik.Secrets.put(scope, "ANTHROPIC_API_KEY", owner: "acme", value: "sk-ant-...", purpose: "api_key")
      #=> :ok

      Wardrik.Secrets.list(scope, owner: "acme")
      #=> {:ok, [%Wardrik.Secret{name: "ANTHROPIC_API_KEY", kind: :api_key}]}

  A secret is read only for its purpose, so a client secret is never read as an API key.

  The owner `"deployment"` holds the deployment's own secrets. `${NAME}` in a daemon's config reads
  them. No agent can, except for API keys where Wardrik starts with `deployment_keys: true`: then
  an agent whose owner holds no `api_key` of a name uses the deployment's. See `Wardrik.Keys`.
  """

  use Wardrik.Operations.Functions, prefix: "secrets"
end
