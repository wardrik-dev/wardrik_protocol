defmodule Wardrik.Scope do
  @moduledoc """
  Who acts through a Wardrik, and on which: the `server` that runs its operations, the Wardrik by
  name, the principal, and the grants its authorizer reads to decide what they may do. `Wardrik.as/3`
  makes one, and `Wardrik.grant/2` adds to it. A scope a token makes names the `policy` every agent
  it defines is held to. An agent's scope carries the `labels` of what its run had read, which the
  messages it sends carry too. A scope a token makes `expires` when it does. While an operation
  runs, it names the operation too.
  """

  alias Wardrik.Statement
  alias WardrikCore.Principal

  @enforce_keys [:server, :wardrik, :principal]
  defstruct [:server, :wardrik, :principal, :operation, :policy, :expires, grants: [], labels: []]

  @type t() :: %__MODULE__{
          server: module(),
          wardrik: atom() | struct(),
          principal: Principal.t(),
          operation: WardrikProtocol.operation() | nil,
          grants: term(),
          policy: String.t() | map() | nil,
          expires: DateTime.t() | nil,
          labels: [String.t()]
        }

  @doc """
  Returns the scope `principal` acts in on the Wardrik named `wardrik`, which `server` runs, allowed
  what `grants` say: a list of `Wardrik.Statement`s, or the options of one.
  """
  @spec new(module(), atom(), Principal.t() | String.t(), term()) :: t()
  def new(server, wardrik, principal, grants \\ [])

  def new(server, wardrik, %Principal{} = principal, grants),
    do: %__MODULE__{
      server: server,
      wardrik: wardrik,
      principal: principal,
      grants: statements(grants)
    }

  def new(server, wardrik, id, grants) when is_binary(id),
    do: new(server, wardrik, %Principal{id: id}, grants)

  @doc "Returns the scope allowed what the statement `opts` describe too."
  @spec grant(t(), keyword()) :: t()
  def grant(%__MODULE__{grants: grants} = scope, opts) when is_list(grants),
    do: %{scope | grants: grants ++ [Statement.new(opts)]}

  @doc "Runs the operation `id` with `input` through the scope's server."
  @spec run(t(), String.t(), map()) :: {:ok, term()} | {:error, Wardrik.Error.t()}
  def run(%__MODULE__{server: server} = scope, id, input), do: server.run(scope, id, input)

  @doc "Streams the operation `id` with `input` through the scope's server."
  @spec stream(t(), String.t(), map()) :: {:ok, Enumerable.t()} | {:error, Wardrik.Error.t()}
  def stream(%__MODULE__{server: server} = scope, id, input), do: server.stream(scope, id, input)

  defp statements([{key, _value} | _rest] = opts) when key in [:roles, :actions, :resources],
    do: [Statement.new(opts)]

  defp statements(grants), do: grants
end
