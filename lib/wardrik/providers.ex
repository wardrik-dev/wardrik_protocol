defmodule Wardrik.Providers do
  @moduledoc """
  Operations on the OAuth apps an org or person adds for their people to sign in with.

      Wardrik.Providers.add(scope, owner: "acme", name: "google", issuer: "https://accounts.google.com")
      #=> {:ok, %Wardrik.Provider{owner: "acme", name: "google", source: :runtime, ...}}

      Wardrik.Providers.list(scope, owner: "acme/@jon")
      #=> {:ok, [%Wardrik.Provider{owner: "acme", name: "google"}, %Wardrik.Provider{owner: "deployment", ...}]}

  `list/2` answers the owner's own, then those it gets along `Wardrik.Owners.chain/1`.
  `remove/3` removes the owner's own alone.
  """

  use Wardrik.Operations.Functions, prefix: "providers"
end
