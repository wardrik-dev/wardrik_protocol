defmodule Wardrik.Test.Server do
  @moduledoc """
  A server that runs nothing: it tells the test each operation it's asked for, and answers with the
  protocol's own example of what the operation gives.
  """

  @behaviour Wardrik.Server

  @event %{
    "specversion" => "1.0",
    "id" => "1",
    "source" => "wardrik://local/agents/acme/triage",
    "type" => "wardrik.run.started",
    "time" => "2026-10-28T12:00:00Z",
    "data" => %{"run" => %{"id" => "r1"}}
  }

  @impl Wardrik.Server
  def run(%Wardrik.Scope{wardrik: test}, id, input) do
    send(test, {:ran, id, input})
    {:ok, example(id)}
  end

  @impl Wardrik.Server
  def stream(%Wardrik.Scope{wardrik: test}, id, input) do
    send(test, {:streamed, id, input})
    {:ok, [{@event, "cursor-1"}]}
  end

  @impl Wardrik.Server
  def follow(_scope, "acme/broken", _input, _opts), do: [{:text, "Half"}, {:failed, :boom}]

  def follow(_scope, "acme/waiting", _input, _opts),
    do: [{:waiting, [%Wardrik.Interrupt{id: "c1", reason: :tool_approval}]}]

  def follow(_scope, _agent, input, _opts),
    do: [
      {:text, "Re: "},
      {:text, input},
      {:done, %Wardrik.Reply{message: "m1", run: "r1", text: "Re: " <> input}}
    ]

  @token %{
    "id" => "3f9a61c0d4e2",
    "name" => "ci",
    "principal" => %{"id" => "acme/@maria"},
    "statements" => [%{"actions" => ["agent.read"], "resources" => ["acme/agent/*"]}],
    "created_at" => "2026-10-28T12:00:00Z"
  }

  @answers %{
    "agents.list" => %{"agents" => [%{"id" => "acme/triage", "name" => "triage"}]},
    "tokens.list" => %{"tokens" => [@token]},
    "tokens.create" => %{"token" => @token, "secret" => "wrk_3f9a61c0d4e2_9c1e"},
    "tokens.revoke" => @token,
    "agent.timeline" => %{"items" => [], "next" => nil},
    "agent.runs" => %{"runs" => [], "totals" => %{}, "next" => nil}
  }

  @doc "Returns whether the server answers the operation `id`: by its example, or with nothing."
  @spec answers?(WardrikProtocol.operation()) :: boolean()
  def answers?(%{id: id, output: output}),
    do: output == nil or Map.has_key?(@answers, id) or match?(%{"examples" => [_ | _]}, output)

  defp example(id) do
    case WardrikProtocol.operation(id).output do
      %{"examples" => [example | _rest]} -> example
      _none -> Map.get(@answers, id)
    end
  end
end
