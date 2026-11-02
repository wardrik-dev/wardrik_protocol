defmodule Wardrik.Agents do
  @moduledoc """
  Operations on every agent the scope can see.

      Wardrik.Agents.list(scope, agents: ["acme/triage", "acme/@jon/notes"])
      #=> {:ok, [%Wardrik.Agent{id: "acme/triage", status: :idle, node: "wardrik@box1", ...}]}
  """

  use Wardrik.Operations.Functions, prefix: "agents"
end
