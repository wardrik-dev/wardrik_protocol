defmodule Wardrik.MCPServers do
  @moduledoc """
  Operations on the MCP servers an org or person adds for their agents at runtime.

      Wardrik.MCPServers.add(scope, owner: "acme", name: "docs", url: "https://docs.example.com/mcp", auth: %{none: %{}})
      #=> {:ok, %Wardrik.MCPServerAdded{server: "docs", connected: true, authorization: nil}}
  """

  use Wardrik.Operations.Functions, prefix: "mcp_servers"
end
