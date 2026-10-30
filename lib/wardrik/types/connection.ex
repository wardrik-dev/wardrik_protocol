defmodule Wardrik.Connection do
  @moduledoc "An account an owner can connect: its `provider`, and whether it's `connected`."

  use Wardrik.Type, schema: ["connection"], fields: [provider: "provider", connected: "connected"]
end

defmodule Wardrik.Connecting do
  @moduledoc """
  The result of connecting an account. If it isn't `connected` yet, `authorization` says where
  the owner signs in.
  """

  use Wardrik.Type,
    schema: ["connecting"],
    fields: [
      provider: "provider",
      connected: "connected",
      authorization: {"authorization", Wardrik.Authorization}
    ]
end
