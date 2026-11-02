defmodule Wardrik.Channel.Installations.Request do
  @moduledoc """
  Which of a channel's installations a `Wardrik.Channel.Installations` callback acts on: the one in
  `workspace`, as the chat app names it, or those `owner` holds.

      %Wardrik.Channel.Installations.Request{channel: "slack", workspace: "T0123"}
      %Wardrik.Channel.Installations.Request{channel: "slack", owner: "acme"}
  """

  @enforce_keys [:channel]
  defstruct [:channel, :workspace, :owner]

  @type t() :: %__MODULE__{
          channel: String.t(),
          workspace: String.t() | nil,
          owner: String.t() | nil
        }
end
