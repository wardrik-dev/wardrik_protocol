defmodule Wardrik.Channel.Installation do
  @moduledoc """
  An installation is a channel added to one workspace, such as a Slack app added to one Slack
  workspace.

      %Wardrik.Channel.Installation{
        channel: "slack",
        workspace: "T0123",
        name: "Acme",
        owner: "acme",
        token: "xoxb-...",
        approvers: ["@maria"]
      }

  `owner` is whose agents answer there: an org, as `acme`, or a person, as `acme/@jon`. `name` is
  what the chat app calls the workspace, where it said. `approvers` names who may decide what those
  agents wait on, as the channel names people, or is `:anyone`. With none named, whoever asked for
  a turn decides it.
  """

  @derive {Inspect, except: [:token]}
  @enforce_keys [:channel, :workspace, :owner, :token]
  defstruct [:channel, :workspace, :owner, :token, :name, approvers: []]

  @type t() :: %__MODULE__{
          channel: String.t(),
          workspace: String.t(),
          owner: String.t(),
          token: String.t(),
          name: String.t() | nil,
          approvers: [String.t()] | :anyone
        }

  @doc "Returns the pattern of the owner's agents' resources, as `acme/agent/*`."
  @spec agents(t()) :: String.t()
  def agents(%__MODULE__{owner: owner}), do: owner <> "/agent/*"
end
