defmodule Wardrik.Server.Follow do
  @moduledoc """
  What `c:Wardrik.Server.follow/2` sends and follows: `input` to `agent`, in `scope`.

      %Wardrik.Server.Follow{scope: scope, agent: "acme/triage", input: "What's on fire?"}
  """

  @enforce_keys [:scope, :agent, :input]
  defstruct [:scope, :agent, :input]

  @type t() :: %__MODULE__{
          scope: Wardrik.Scope.t(),
          agent: String.t() | struct(),
          input: term()
        }
end
