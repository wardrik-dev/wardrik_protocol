defmodule Wardrik.NotifyTargets do
  @moduledoc """
  Operations on the webhooks an org or person adds for their agents' notices.

      Wardrik.NotifyTargets.add(scope, owner: "acme", name: "ops", url: "https://hooks.acme.example/wardrik", secret: %{name: "OPS_HOOK_SECRET"})
      #=> {:ok, %Wardrik.NotifyTarget{owner: "acme", name: "ops", source: :runtime, kind: "webhook", ...}}

      Wardrik.NotifyTargets.list(scope, owner: "acme/@jon")
      #=> {:ok, [%Wardrik.NotifyTarget{owner: "acme", name: "ops"}, %Wardrik.NotifyTarget{owner: "deployment", ...}]}

  `list/2` answers the owner's own, then those it gets along `Wardrik.Owners.chain/1`, the nearest
  of a name winning. `remove/3` removes the owner's own alone.
  """

  use Wardrik.Operations.Functions, prefix: "notify_targets"
end
