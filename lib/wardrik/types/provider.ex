defmodule Wardrik.Provider do
  @moduledoc """
  An OAuth app people sign in with. `owner` holds it, and `source` is `:config` for one the
  deployment started with, or `:runtime` for one added since. `client_secret` is the name of the
  vault secret that holds its client secret, never the secret itself.
  """

  use Wardrik.Type,
    schema: ["provider"],
    fields: [
      owner: "owner",
      name: "name",
      source: {"source", [:config, :runtime]},
      issuer: "issuer",
      resource: "resource",
      authorization_endpoint: "authorization_endpoint",
      token_endpoint: "token_endpoint",
      client_id: "client_id",
      client_secret: "client_secret.name",
      client_auth: {"client_auth", [:post, :basic]},
      scopes: "scopes",
      flow: {"flow", [:browser, :device]},
      authorization_params: "authorization_params"
    ]
end
