defmodule Wardrik.Statement do
  @moduledoc """
  Allows actions on the resources its patterns match, like an IAM statement.

      Wardrik.Statement.new(roles: [:reader, :messenger], resources: ["acme/agent/*"])
      Wardrik.Statement.new(actions: ["agent.*"], resources: ["acme/@jon/*"])

  In a pattern, `*` matches any run of characters, including `/`. `?` matches one character.

  ## Roles

  A role is a named set of actions:

  | Role | Actions |
  | --- | --- |
  | `:reader` | `agent.read`, `agent.events`, `connection.read`, `mcp_server.read`, `provider.read`, `notify_target.read`, `ceiling.read` |
  | `:messenger` | `agent.ask`, `agent.cancel`, `agent.clear` |
  | `:approver` | `agent.decide` |
  | `:definer` | `agent.define`, `agent.spawn`, `agent.stop`, `agent.forget`, `connection.connect`, `mcp_server.add`, `provider.add`, `notify_target.add` |
  | `:worker` | `agent.serve`, offering tools to the agents it covers |
  | `:owner` | every action |
  """

  @enforce_keys [:actions, :resources]
  defstruct @enforce_keys

  @type t() :: %__MODULE__{actions: [String.t()], resources: [String.t()]}

  @roles %{
    reader: [
      "agent.read",
      "agent.events",
      "connection.read",
      "mcp_server.read",
      "provider.read",
      "notify_target.read",
      "ceiling.read"
    ],
    messenger: ["agent.ask", "agent.cancel", "agent.clear"],
    approver: ["agent.decide"],
    definer: [
      "agent.define",
      "agent.spawn",
      "agent.stop",
      "agent.forget",
      "connection.connect",
      "mcp_server.add",
      "provider.add",
      "notify_target.add"
    ],
    worker: ["agent.serve"],
    owner: ["*"]
  }

  @doc "Returns `{:ok, role}` for a role's name, as `:reader` for `\"reader\"`, or `:error`."
  @spec role(String.t()) :: {:ok, atom()} | :error
  def role(name),
    do: Map.fetch(Map.new(@roles, fn {role, _actions} -> {Atom.to_string(role), role} end), name)

  @doc "Builds a statement from the protocol's JSON."
  @spec from_json(map()) :: t()
  def from_json(%{"actions" => actions, "resources" => resources}),
    do: %__MODULE__{actions: actions, resources: resources}

  @doc "Returns the statement as the protocol's JSON."
  @spec to_json(t()) :: map()
  def to_json(%__MODULE__{actions: actions, resources: resources}),
    do: %{"actions" => actions, "resources" => resources}

  @doc """
  Builds a statement.

      Wardrik.Statement.new(roles: [:reader], actions: ["agent.ask"], resources: ["acme/agent/*"])

  ## Options

    * `:resources` - patterns of the resources it covers.
    * `:actions` - actions it allows. `[]` unless set.
    * `:roles` - roles whose actions it allows too. `[]` unless set.

  Raises `ArgumentError` for an unknown option, and `KeyError` for an unknown role.
  """
  @spec new(keyword()) :: t()
  def new(opts) do
    opts = Keyword.validate!(opts, [:resources, actions: [], roles: []])
    roles = Enum.flat_map(opts[:roles], &Map.fetch!(@roles, &1))

    %__MODULE__{actions: Enum.uniq(opts[:actions] ++ roles), resources: opts[:resources]}
  end
end
