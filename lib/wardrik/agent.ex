defmodule Wardrik.Agent do
  @moduledoc """
  An agent, and the operations on one.

      Wardrik.Agent.ask(scope, "acme/triage", "What's on fire?")
      #=> {:ok, %Wardrik.Message{id: "msg_Xq3f...", cursor: "eyJhY21lL3RyaWFnZSI6NDF9"}}

      Wardrik.Agent.read(scope, "acme/triage")
      #=> {:ok, %Wardrik.Agent{id: "acme/triage", status: :running, node: "wardrik@box1", pending: 0, ...}}

  ## Fields

    * `:id` - the agent's ID, as `"acme/triage"`.
    * `:name` - its name.
    * `:status` - `:idle`, `:running`, `:parked` or `:asleep`.
    * `:node` - the node it runs on.
    * `:pending` - how many messages wait behind the current one.
    * `:next_run` - when it next runs.
    * `:spent_today` - what it has spent today.
    * `:activity` - what it's doing now. See `Wardrik.Activity`.
    * `:interrupts` - the calls it waits on a person for. See `Wardrik.Interrupt`.
    * `:cursor` - where its event log stands.

  Agents from `Wardrik.Agents.list/2` leave out `:activity`, `:interrupts` and `:cursor`.
  """

  use Wardrik.Type,
    schema: ["agent_snapshot"],
    fields: [
      id: "agent.id",
      name: "agent.name",
      status: {"status", [:idle, :running, :parked, :asleep]},
      node: "node",
      pending: "pending",
      next_run: {"next_run", :datetime},
      spent_today: "spent_today",
      activity: {"activity", Wardrik.Activity},
      interrupts: {"interrupts", [Wardrik.Interrupt]},
      cursor: "cursor"
    ]

  use Wardrik.Operations.Functions, prefix: "agent"

  @doc """
  Sends the agent a message and streams the text of its answer.

      scope |> Wardrik.Agent.stream("acme/triage", "What's on fire?") |> Enum.each(&IO.write/1)

  The stream ends when the run ends, including when it fails. Use `reply/4` to see how it ended.
  Raises `Wardrik.Error` if the agent can't be reached.

  With `to: pid`, returns `{:ok, ref}` and sends `pid` each item as `{Wardrik, ref, item}`:

    1. `{:text, chunk}`, any number of times.
    2. One of `{:done, %Wardrik.Reply{}}`, `{:waiting, interrupts}` or `{:failed, why}`.

  ## Options

    * `:to` - a pid to send the answer to, in place of returning a stream.
    * `:timeout` - milliseconds to wait for each part of the answer. Ten minutes unless set.
  """
  @spec stream(Wardrik.Scope.t(), String.t() | t(), term(), keyword()) ::
          Enumerable.t() | {:ok, reference()}
  def stream(scope, agent, input, opts \\ []) do
    case Keyword.fetch(opts, :to) do
      {:ok, pid} -> send_to(scope, agent, input, pid, opts)
      :error -> scope |> follow(agent, input, opts) |> Stream.flat_map(&text/1)
    end
  end

  @doc """
  Sends the agent a message and returns its answer once the run ends.

      Wardrik.Agent.reply(scope, "acme/triage", "What's on fire?")
      #=> {:ok, %Wardrik.Reply{message: "msg_Xq3f...", run: "0af76519...", text: "Nothing's on fire."}}

  Returns `{:waiting, interrupts}` if the run waits on a person. Returns `{:error, %Wardrik.Error{}}`
  if the agent can't be reached or the run fails. Takes the `:timeout` option of `stream/4`.
  """
  @spec reply(Wardrik.Scope.t(), String.t() | t(), term(), keyword()) ::
          {:ok, Wardrik.Reply.t()}
          | {:waiting, [Wardrik.Interrupt.t()]}
          | {:error, Wardrik.Error.t()}
  def reply(scope, agent, input, opts \\ []) do
    scope
    |> follow(agent, input, opts)
    |> Enum.reduce(nil, &ended/2)
  rescue
    error in Wardrik.Error -> {:error, error}
  end

  defp follow(%Wardrik.Scope{server: server} = scope, agent, input, opts),
    do: server.follow(scope, agent, input, opts)

  defp send_to(scope, agent, input, pid, opts) do
    ref = make_ref()

    {:ok, _task} =
      Task.start(fn ->
        scope
        |> follow(agent, input, opts)
        |> Enum.each(&send(pid, {Wardrik, ref, &1}))
      end)

    {:ok, ref}
  end

  defp ended({:done, reply}, _acc), do: {:ok, reply}
  defp ended({:waiting, interrupts}, _acc), do: {:waiting, interrupts}

  defp ended({:failed, why}, _acc),
    do: {:error, Wardrik.Error.new(:unavailable, "The run failed: #{why}")}

  defp ended({:text, _chunk}, acc), do: acc

  defp text({:text, chunk}), do: [chunk]
  defp text(_ended), do: []

  @doc "Builds an agent from one item of the `agents.list` output."
  @spec from_summary(map()) :: t()
  def from_summary(%{"id" => id, "name" => name} = summary),
    do:
      from_json(%{
        "agent" => %{"id" => id, "name" => name},
        "status" => summary["status"],
        "node" => summary["node"],
        "pending" => summary["pending"],
        "next_run" => summary["next_run"],
        "spent_today" => summary["spent_today"]
      })
end
