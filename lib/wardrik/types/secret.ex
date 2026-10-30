defmodule Wardrik.Secret do
  @moduledoc "A secret an owner holds, by `name`. `kind` is `:secret` for one they sealed, or `:grant` for an account they connected."

  use Wardrik.Type,
    schema: ["secrets", "properties", "secrets", "items"],
    fields: [name: "name", kind: {"kind", [:secret, :grant]}]
end
