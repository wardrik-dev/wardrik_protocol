defmodule Wardrik.Resource do
  @moduledoc """
  Names what an action acts on, as IAM resources do.

  | Resource | Names |
  | --- | --- |
  | `acme/agent/triage` | the agent `acme/triage` |
  | `acme/@jon/agent/triage` | the agent `acme/@jon/triage` |
  | `acme/mcp_server/linear` | the org's MCP server `linear` |
  | `acme/@jon/connection/github` | Jon's GitHub account |
  | `deployment` | the deployment |
  """

  alias Wardrik.AgentID

  @deployment "deployment"

  @doc """
  Returns the resource for the agent `id`, or `:error` if it isn't an agent ID.

      Wardrik.Resource.agent("acme/triage")
      #=> {:ok, "acme/agent/triage"}

      Wardrik.Resource.agent("acme/triage/C1-1696.1234")
      #=> {:ok, "acme/agent/triage/conversation/C1-1696.1234"}
  """
  @spec agent(String.t()) :: {:ok, String.t()} | :error
  def agent(id) do
    case AgentID.parse(id) do
      {:ok, %AgentID{owner: owner, name: name, conversation: nil}} ->
        {:ok, owner <> "/agent/" <> name}

      {:ok, %AgentID{owner: owner, name: name, conversation: conversation}} ->
        {:ok, owner <> "/agent/" <> name <> "/conversation/" <> conversation}

      :error ->
        :error
    end
  end

  @doc """
  Returns the resource for something `owner` holds: every item of `kind`, or the one `name`d.

      Wardrik.Resource.owned("acme", "mcp_server", "linear")
      #=> "acme/mcp_server/linear"
  """
  @spec owned(String.t(), String.t(), String.t() | nil) :: String.t()
  def owned(owner, kind, nil), do: owner <> "/" <> kind
  def owned(owner, kind, name), do: owner <> "/" <> kind <> "/" <> name

  @doc "Returns the deployment's resource."
  @spec deployment() :: String.t()
  def deployment, do: @deployment
end
