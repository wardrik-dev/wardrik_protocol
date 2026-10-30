defmodule Wardrik.MCPServer do
  @moduledoc """
  An MCP server an owner added for their agents: its `name`, `url`, and `auth`. `auth` is how
  agents sign in to it: `:oauth`, `:secret` or `:none`.
  """

  use Wardrik.Type,
    schema: ["server"],
    fields: [name: "name", url: "url", auth: {"auth", [:oauth, :secret, :none]}]
end

defmodule Wardrik.MCPServerAdded do
  @moduledoc """
  The result of adding an MCP server. If it isn't `connected` yet, `authorization` says where
  someone signs in first.
  """

  use Wardrik.Type,
    schema: ["server_added"],
    fields: [
      server: "server",
      connected: "connected",
      authorization: {"authorization", Wardrik.Authorization}
    ]
end
