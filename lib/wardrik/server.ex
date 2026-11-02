defmodule Wardrik.Server do
  @moduledoc """
  A behaviour for what runs Wardrik's operations.

  `Wardrik.Agent`, `Wardrik.Tokens` and the other typed modules call the server their
  `Wardrik.Scope` names. Packages built on the protocol call those modules without depending on
  the server. The `wardrik` hub implements it.
  """

  @doc "Runs the request's operation with its input, shaped as its input schema describes."
  @callback run(Wardrik.Server.Request.t()) :: {:ok, term()} | {:error, Wardrik.Error.t()}

  @doc "Runs the request's streamed operation. Streams `{event, cursor}` pairs: stored events, then new ones as they arrive."
  @callback stream(Wardrik.Server.Request.t()) ::
              {:ok, Enumerable.t()} | {:error, Wardrik.Error.t()}

  @doc """
  Sends the input to the agent and streams its answer, in order:

    1. `{:text, chunk}`, any number of times.
    2. One of `{:done, %Wardrik.Reply{}}`, `{:waiting, interrupts}` or `{:failed, why}`.

  Raises `Wardrik.Error` if the agent can't be reached.
  """
  @callback follow(Wardrik.Server.Follow.t(), opts :: keyword()) :: Enumerable.t()

  @doc "Returns the scope an API token's `secret` acts in on `wardrik`, or an error."
  @callback authenticate(wardrik :: atom(), secret :: String.t()) ::
              {:ok, Wardrik.Scope.t()} | {:error, Wardrik.Error.t()}

  @doc """
  Offers a worker's tools, as MCP's `tools/list` returns them, to the agents `scope` may serve.

  The calling process then receives:

    * `{Wardrik.Workers, :call, call, name, arguments, meta}` for each call to a tool.
    * `{Wardrik.Workers, :cancel, call}` when a call is cancelled.
  """
  @callback offer(Wardrik.Scope.t(), tools :: [map()]) :: :ok | {:error, term()}

  @doc "Answers the worker's `call` with the JSON-RPC `message`."
  @callback answer(call :: term(), message :: map()) :: :ok
end
