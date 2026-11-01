defmodule Wardrik.Secret do
  @moduledoc """
  A secret an owner holds, by `name`. `kind` says what it's for: `:api_key`, `:client_secret`,
  `:header` or `:signing_secret` for one they sealed, `:grant` for an account they connected, or
  `:token` for a chat app's install. `:secret` is one sealed with no purpose.
  """

  use Wardrik.Type,
    schema: ["secrets", "properties", "secrets", "items"],
    fields: [
      name: "name",
      kind:
        {"kind", [:secret, :grant, :api_key, :client_secret, :header, :signing_secret, :token]}
    ]
end
