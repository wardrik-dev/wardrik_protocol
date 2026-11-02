defmodule Wardrik.Resource do
  @moduledoc """
  Names the deployment, the owner every settings chain ends at. See `Wardrik.Owners.chain/1`.
  """

  @deployment "deployment"

  @doc "Returns the deployment's name as an owner."
  @spec deployment() :: String.t()
  def deployment, do: @deployment
end
