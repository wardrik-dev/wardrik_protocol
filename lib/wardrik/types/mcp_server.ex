defmodule Wardrik.MCPServer do
  @moduledoc """
  An MCP server an owner's agents reach. `owner` holds it, and `source` is `:config` for one the
  deployment started with, or `:runtime` for one added since. `auth` is how agents sign in to it:
  `:oauth`, `:secret` or `:none`. `url` is `nil` for a command the deployment starts.
  """

  use Wardrik.Type,
    schema: ["server"],
    fields: [
      owner: "owner",
      name: "name",
      source: {"source", [:config, :runtime]},
      url: "url",
      auth: {"auth", [:oauth, :secret, :none]}
    ]
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
