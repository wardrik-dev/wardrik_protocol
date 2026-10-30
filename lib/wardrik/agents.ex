defmodule Wardrik.Agents do
  @moduledoc """
  Operations on every agent the scope can see.

      Wardrik.Agents.list(scope, resources: ["acme/agent/*"])
      #=> {:ok, [%Wardrik.Agent{id: "acme/triage", status: :idle, node: "wardrik@box1", ...}]}
  """

  use Wardrik.Operations.Functions, prefix: "agents"
end
