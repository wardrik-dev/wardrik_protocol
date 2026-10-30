defmodule Wardrik.Token do
  @moduledoc """
  An API token, without its secret.

    * `:id` and `:name` - which token.
    * `:principal` - the ID of the principal it acts for.
    * `:statements` - what it allows, as `Wardrik.Statement`s.
    * `:policy` - the policy every agent it defines is held to.
    * `:expires` - when it expires.
    * `:created_at` - when it was made.
  """

  use Wardrik.Type,
    schema: ["token"],
    fields: [
      id: "id",
      name: "name",
      principal: "principal.id",
      statements: {"statements", [Wardrik.Statement]},
      policy: "policy",
      expires: {"expires", :datetime},
      created_at: {"created_at", :datetime}
    ]
end

defmodule Wardrik.TokenIssued do
  @moduledoc "A new token and its `secret`. The secret is returned only once. Send it as `Authorization: Bearer <secret>`."

  use Wardrik.Type,
    schema: ["token_issued"],
    fields: [token: {"token", Wardrik.Token}, secret: "secret"]
end
