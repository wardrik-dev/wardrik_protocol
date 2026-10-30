defmodule Wardrik.Tokens do
  @moduledoc """
  Operations on the deployment's API tokens. People and programs use them to reach Wardrik over
  HTTP.

      Wardrik.Tokens.create(scope, name: "ci", roles: ["reader"], resources: ["acme/agent/*"])
      #=> {:ok, %Wardrik.TokenIssued{token: %Wardrik.Token{id: "3f9a61c0d4e2", ...}, secret: "wrk_3f9a61c0d4e2_9c1e..."}}

      # The secret is returned once. Turn it back into a scope with:
      {:ok, ci} = MyApp.Wardrik.authenticate("wrk_3f9a61c0d4e2_9c1e...")
  """

  use Wardrik.Operations.Functions, prefix: "tokens"
end
