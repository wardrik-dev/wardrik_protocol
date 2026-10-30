defmodule Wardrik.Nodes do
  @moduledoc "The deployment's `nodes`, and how many agents are `asleep`."

  use Wardrik.Type,
    schema: ["nodes"],
    fields: [nodes: {"nodes", [Wardrik.Node]}, asleep: "asleep"]
end

defmodule Wardrik.Node do
  @moduledoc "One of the deployment's nodes: its `name`, and how many `agents` run on it."

  use Wardrik.Type,
    schema: ["nodes", "properties", "nodes", "items"],
    fields: [name: "name", agents: "agents"]
end
