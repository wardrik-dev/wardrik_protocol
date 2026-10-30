defmodule Wardrik.Channel.Installations do
  @moduledoc """
  A behaviour for storing the workspaces a channel is added to, each with its token.

  Pass an implementation to a channel as `installations: {module, config}`. The host then keeps
  workspaces with its own records. A channel given `token:` instead serves only the workspace that
  token reaches.

  Tokens are secrets. Store them as you store your others.
  """

  alias Wardrik.Channel.Installation

  @doc "Fetches the channel's installation in `workspace`, as the chat app names it."
  @callback fetch(config :: term(), channel :: String.t(), workspace :: String.t()) ::
              {:ok, Installation.t()} | :error

  @doc "Returns the channel's installations owned by `owner`, as `acme` or `acme/@jon`."
  @callback owned(config :: term(), channel :: String.t(), owner :: String.t()) :: [
              Installation.t()
            ]

  @doc "Stores `installation`, replacing any with the same channel and workspace."
  @callback put(config :: term(), Installation.t()) :: :ok | {:error, String.t()}

  @doc "Deletes the channel's installation in `workspace`. Returns `:ok` if there is none."
  @callback delete(config :: term(), channel :: String.t(), workspace :: String.t()) :: :ok
end
