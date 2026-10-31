defmodule Wardrik.MCPServers do
  @moduledoc """
  Operations on the MCP servers an org or person adds for their agents at runtime.

      Wardrik.MCPServers.add(scope, owner: "acme", name: "docs", url: "https://docs.example.com/mcp", auth: %{none: %{}})
      #=> {:ok, %Wardrik.MCPServerAdded{server: "docs", connected: true, authorization: nil}}

      Wardrik.MCPServers.list(scope, owner: "acme/@jon")
      #=> {:ok, [%Wardrik.MCPServer{owner: "acme", name: "docs", source: :runtime, ...}, %Wardrik.MCPServer{owner: "deployment", ...}]}

  `list/2` answers the owner's own, then those it gets along `Wardrik.Owners.chain/1`, the nearest
  of a name winning. `remove/3` removes the owner's own alone.
  """

  use Wardrik.Operations.Functions, prefix: "mcp_servers"
end
