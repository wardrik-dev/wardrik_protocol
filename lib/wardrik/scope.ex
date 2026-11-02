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
  Returns a scope for `:principal` on `:wardrik`, run by `server`.

      Wardrik.Scope.new(Wardrik,
        wardrik: MyApp.AgentRuntime,
        principal: "acme/@maria",
        grants: [roles: [:owner], resources: ["acme/@maria/*"]]
      )

  `:principal` is a `WardrikCore.Principal` or its ID. `:grants` is a list of
  `Wardrik.Statement`s, or the options for one. `[]` unless set.
  """
  @spec new(module(),
          wardrik: atom() | struct(),
          principal: Principal.t() | String.t(),
          grants: term()
        ) :: t()
  def new(server, args) do
    %__MODULE__{
      server: server,
      wardrik: Keyword.fetch!(args, :wardrik),
      principal: args |> Keyword.fetch!(:principal) |> principal(),
      grants: args |> Keyword.get(:grants, []) |> statements()
    }
  end

  @doc "Adds a statement built from `opts` to the scope's grants. See `Wardrik.Statement.new/1`."
  @spec grant(t(), keyword()) :: t()
  def grant(%__MODULE__{grants: grants} = scope, opts) when is_list(grants),
    do: %{scope | grants: grants ++ [Statement.new(opts)]}

  @doc "Runs operation `id` with `input` through the scope's server."
  @spec run(t(), String.t(), map()) :: {:ok, term()} | {:error, Wardrik.Error.t()}
  def run(%__MODULE__{server: server} = scope, id, input),
    do: server.run(%Wardrik.Server.Request{scope: scope, operation: id, input: input})

  @doc "Streams operation `id` with `input` through the scope's server."
  @spec stream(t(), String.t(), map()) :: {:ok, Enumerable.t()} | {:error, Wardrik.Error.t()}
  def stream(%__MODULE__{server: server} = scope, id, input),
    do: server.stream(%Wardrik.Server.Request{scope: scope, operation: id, input: input})

  defp principal(%Principal{} = principal), do: principal
  defp principal(id) when is_binary(id), do: %Principal{id: id}

  defp statements([{key, _value} | _rest] = opts) when key in [:roles, :actions, :resources],
    do: [Statement.new(opts)]

  defp statements(grants), do: grants
end
