defmodule Wardrik.Server do
  @moduledoc """
  What runs Wardrik's operations, as `Wardrik.Scope` names it in `server`. The typed functions of
  `Wardrik.Agent`, `Wardrik.Tokens` and the rest call it, so a package built on the protocol calls
  them without depending on what runs them. The `wardrik` hub is one.
  """

  @doc "Runs the operation `id`, with `input` as its input schema describes it."
  @callback run(Wardrik.Scope.t(), String.t(), map()) ::
              {:ok, term()} | {:error, Wardrik.Error.t()}

  @doc "Runs the streamed operation `id`, as `{event, cursor}` pairs that read on and then follow."
  @callback stream(Wardrik.Scope.t(), String.t(), map()) ::
              {:ok, Enumerable.t()} | {:error, Wardrik.Error.t()}

  @doc """
  Sends `input` to `agent`, and streams what its answer brings, in order: `{:text, chunk}`, then
  `{:done, %Wardrik.Reply{}}`, `{:waiting, interrupts}` or `{:failed, reason}`. Raises a
  `Wardrik.Error` where the agent can't be reached.
  """
  @callback follow(Wardrik.Scope.t(), String.t() | struct(), term(), keyword()) :: Enumerable.t()

  @doc "Returns the scope an API token's `secret` acts in on the Wardrik named `wardrik`, or why it has none."
  @callback authenticate(wardrik :: atom(), secret :: String.t()) ::
              {:ok, Wardrik.Scope.t()} | {:error, Wardrik.Error.t()}

  @doc """
  Offers the tools a worker lists, as MCP's `tools/list` gives them, to the agents `scope` may serve.
  Each call to one reaches the calling process as `{Wardrik.Workers, :call, call, name, arguments,
  meta}`, and its cancellation as `{Wardrik.Workers, :cancel, call}`.
  """
  @callback offer(Wardrik.Scope.t(), tools :: [map()]) :: :ok | {:error, term()}

  @doc "Answers the worker's `call` with its JSON-RPC `message`."
  @callback answer(call :: term(), message :: map()) :: :ok
end
