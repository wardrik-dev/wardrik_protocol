defmodule Wardrik.Events do
  @moduledoc """
  Operations on the events of every agent the scope can see.

      {:ok, cursor} = Wardrik.Events.head(scope)
      {:ok, stream} = Wardrik.Events.stream_list(scope, after: cursor)
  """

  use Wardrik.Operations.Functions, prefix: "events"
end
