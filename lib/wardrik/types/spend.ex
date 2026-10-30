defmodule Wardrik.Spend do
  @moduledoc """
  What an org's agents have spent against one ceiling in its current period.
  See `Wardrik.Ceiling`.

    * `:ceiling` - the ceiling's name.
    * `:limit` - its limit, as a `Wardrik.Amount`.
    * `:spent` - what the agents have spent.
    * `:granted` - what approvals added.
    * `:per` - the period: `:day`, `:week`, `:month` or `:total`.
    * `:on_exhausted` - what the next call does once it's spent: `:ask`, `:deny` or `:continue`.
    * `:starts_over` - the day the period resets. `nil` for `:total`.
  """

  use Wardrik.Type,
    schema: ["ceilings", "properties", "ceilings", "items"],
    fields: [
      ceiling: "ceiling",
      per: {"per", [:day, :week, :month, :total]},
      on_exhausted: {"on_exhausted", [:ask, :deny, :continue]},
      limit: {"limit", Wardrik.Amount},
      spent: {"spent", Wardrik.Amount},
      granted: {"granted", Wardrik.Amount},
      starts_over: {"starts_over", :date}
    ]
end

defmodule Wardrik.Amount do
  @moduledoc "An amount in US dollars (`usd`), tokens (`tokens`), or both. A limit leaves out what it doesn't limit."

  use Wardrik.Type,
    schema: ["defs", "$defs", "amount"],
    fields: [usd: "usd", tokens: "tokens"]
end
