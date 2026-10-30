defmodule Wardrik.Ceilings do
  @moduledoc """
  Operations on an org's ceilings: the budgets its agents share.

      Wardrik.Ceilings.list(scope, owner: "acme")
      #=> {:ok, [%Wardrik.Spend{ceiling: "plan", limit: %Wardrik.Amount{usd: 20.0}, ...}]}

  Reading them needs `ceiling.read` on the org's `acme/ceiling`. The `:reader` role has it.
  Approving a call past a ceiling needs `ceiling.approve`. The `:owner` role has it.
  See `Wardrik.Ceiling`.
  """

  use Wardrik.Operations.Functions, prefix: "ceilings"
end
