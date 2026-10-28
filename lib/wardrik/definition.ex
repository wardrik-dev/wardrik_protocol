defmodule Wardrik.Definition do
  @moduledoc """
  A definition says what an agent is and what it may do, as an agent file's frontmatter does, with
  the keys the protocol's `agent_definition` gives it. Build one with `new!/1`:

      definition =
        Wardrik.Definition.new!(
          model: "anthropic:claude-haiku-4-5",
          instructions: "You watch the incident queue.",
          tools: ["linear/*"],
          policy: [ask: ["linear/*"]]
        )

      Wardrik.Agent.define(scope, "acme/triage", definition)
      #=> {:ok, %Wardrik.Agent{id: "acme/triage", status: :idle, ...}}

  Each tool and policy it names is one the Wardrik offers; see `Wardrik.start_link/1`. `policy`,
  `workspace`, `context`, `retries`, `compaction` and `notify` are kept as the protocol writes them,
  and each of `triggers` is a `Wardrik.Trigger`.
  """

  use Wardrik.Type,
    schema: ["agent_definition"],
    fields: [
      display_name: "display_name",
      description: "description",
      instructions: "instructions",
      model: "model",
      tools: "tools",
      workspace: "workspace",
      context: "context",
      policy: "policy",
      timeout: "timeout",
      idle_timeout: {"idle_timeout", :infinity},
      max_iterations: {"max_iterations", :infinity},
      retries: "retries",
      compaction: "compaction",
      triggers: {"triggers", [Wardrik.Trigger]},
      notify: "notify",
      channels: "channels"
    ]

  alias Wardrik.AgentID
  alias Wardrik.Type
  alias WardrikCore.Principal

  @schema JSV.build!(WardrikProtocol.schema("agent_definition"))

  @doc "Builds a definition from a keyword list or a map. Raises if it doesn't read."
  @spec new!(keyword() | map()) :: t()
  def new!(fields) do
    json = Type.json(fields)

    case JSV.validate(json, @schema) do
      {:ok, _valid} -> from_json(json)
      {:error, error} -> raise ArgumentError, Exception.message(error)
    end
  end

  @doc "Returns the definition with each of its triggers named, `trigger-1` and so on by its place unless it says."
  @spec named(map()) :: map()
  def named(%{"triggers" => triggers} = definition) do
    named =
      triggers
      |> Enum.with_index(1)
      |> Enum.map(fn {trigger, index} -> Map.put_new(trigger, "name", "trigger-#{index}") end)

    %{definition | "triggers" => named}
  end

  def named(definition), do: definition

  @doc "Returns who the agent `id` acts as: its user, as `acme/@maria`, or its org, as `acme`."
  @spec principal(String.t()) :: Principal.t()
  def principal(id) do
    {:ok, %AgentID{owner: owner}} = AgentID.parse(id)
    %Principal{id: owner}
  end
end
