defmodule Wardrik.Channel.Notification do
  @moduledoc """
  What `c:Wardrik.Channel.notify/2` posts: `notice`, in `room`, asking `approvers` to decide the
  calls a parked turn waits on.

      %Wardrik.Channel.Notification{room: "#ops", notice: notice, approvers: ["U024BE7LH"]}

  `approvers` are named as the chat app names people.
  """

  @enforce_keys [:room, :notice]
  defstruct [:room, :notice, approvers: []]

  @type t() :: %__MODULE__{
          room: String.t(),
          notice: Wardrik.Notice.t(),
          approvers: [String.t()]
        }
end
