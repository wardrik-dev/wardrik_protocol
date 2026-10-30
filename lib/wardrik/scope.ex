defmodule Wardrik.Scope do
  @moduledoc """
  Who is acting through Wardrik, and what they may do.

      scope = MyApp.AgentRuntime.as("acme/@maria", roles: [:owner], resources: ["acme/@maria/*"])

  `Wardrik.as/3` makes a scope. `Wardrik.grant/2` adds to it.

  ## Fields

    * `:server` - the `Wardrik.Server` that runs its operations.
    * `:wardrik` - which Wardrik, by name.
    * `:principal` - who is acting.
    * `:grants` - what the authorizer reads to decide what they may do.
    * `:policy` - in a token's scope, the policy every agent it defines is held to.
    * `:expires` - in a token's scope, when the token expires.
    * `:labels` - in an agent's scope, the labels of what its run has read. Messages it sends
      carry them too.
    * `:operation` - the operation running, while one runs.
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
  Returns a scope for `principal` on `wardrik`, run by `server`.

  `grants` is a list of `Wardrik.Statement`s, or the options for one.
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

  @doc "Adds a statement built from `opts` to the scope's grants. See `Wardrik.Statement.new/1`."
  @spec grant(t(), keyword()) :: t()
  def grant(%__MODULE__{grants: grants} = scope, opts) when is_list(grants),
    do: %{scope | grants: grants ++ [Statement.new(opts)]}

  @doc "Runs operation `id` with `input` through the scope's server."
  @spec run(t(), String.t(), map()) :: {:ok, term()} | {:error, Wardrik.Error.t()}
  def run(%__MODULE__{server: server} = scope, id, input), do: server.run(scope, id, input)

  @doc "Streams operation `id` with `input` through the scope's server."
  @spec stream(t(), String.t(), map()) :: {:ok, Enumerable.t()} | {:error, Wardrik.Error.t()}
  def stream(%__MODULE__{server: server} = scope, id, input), do: server.stream(scope, id, input)

  defp statements([{key, _value} | _rest] = opts) when key in [:roles, :actions, :resources],
    do: [Statement.new(opts)]

  defp statements(grants), do: grants
end
