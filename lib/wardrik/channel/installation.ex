defmodule Wardrik.Channel.Installation do
  @moduledoc """
  A channel added to one workspace, such as a Slack app added to one Slack workspace.

      %Wardrik.Channel.Installation{
        channel: "slack",
        workspace: "T0123",
        name: "Acme",
        owner: "acme",
        token: "xoxb-...",
        approvers: ["@maria"]
      }

  ## Fields

    * `:channel` - the channel's name, as `"slack"`.
    * `:workspace` - the workspace's ID in the chat app.
    * `:owner` - whose agents answer there: an org, as `"acme"`, or a person, as `"acme/@jon"`.
    * `:token` - the chat app's token for the workspace. Hidden from `inspect/2`.
    * `:name` - the workspace's name in the chat app, if it gave one.
    * `:approvers` - who may decide the calls those agents wait on, named as the chat app names
      people, or `:anyone`. With `[]`, the person who started the turn decides.
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

  @doc "Returns the resource pattern for the owner's agents, as `acme/agent/*`."
  @spec agents(t()) :: String.t()
  def agents(%__MODULE__{owner: owner}), do: owner <> "/agent/*"
end
