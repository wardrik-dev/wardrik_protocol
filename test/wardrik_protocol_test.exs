defmodule WardrikProtocolTest do
  use ExUnit.Case, async: true

  @event %{
    "specversion" => "1.0",
    "id" => "0199a3c2-5f1e-7c3a-9d2b-4e8f1a6b7c90",
    "source" => "wardrik://local/agents/acme/triage",
    "type" => "wardrik.tool_call.started",
    "subject" => "tool_calls/call_1",
    "time" => "2026-10-01T12:04:01.540213Z",
    "datacontenttype" => "application/json",
    "dataschema" => "urn:wardrik:schema:v1:tool_call.started",
    "traceparent" => "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01",
    "parentspanid" => "a3ce929d0e0e4736",
    "sequence" => "000000000042",
    "data" => %{
      "tool" => %{
        "name" => "linear__search_issues",
        "call" => %{"id" => "call_1", "arguments" => %{}}
      },
      "decided" => %{"by" => "default"}
    }
  }

  defp valid?(name, value),
    do: match?({:ok, _value}, JSV.validate(value, JSV.build!(WardrikProtocol.schema(name))))

  test "lists every event's type" do
    assert Enum.count(WardrikProtocol.types()) == 48
    assert "wardrik.run.started" in WardrikProtocol.types()

    assert WardrikProtocol.dataschema("wardrik.run.started") ==
             "urn:wardrik:schema:v1:run.started"
  end

  test "builds every schema whole, with nothing left to resolve" do
    for name <- [
          "cloudevent",
          "defs" | Enum.map(WardrikProtocol.types(), &String.trim_leading(&1, "wardrik."))
        ] do
      schema = WardrikProtocol.schema(name)
      refute inspect(schema) =~ "$ref"
      assert %JSV.Root{} = JSV.build!(schema)
    end
  end

  test "checks an event and its data" do
    assert valid?("cloudevent", @event)
    assert valid?("tool_call.started", @event["data"])

    refute valid?("cloudevent", Map.delete(@event, "traceparent"))
    refute valid?("tool_call.started", Map.delete(@event["data"], "decided"))
  end

  test "says which events are never kept" do
    live = Enum.filter(WardrikProtocol.types(), &WardrikProtocol.live?/1)

    assert Enum.sort(live) == [
             "wardrik.activity.changed",
             "wardrik.message.delta",
             "wardrik.reasoning.delta",
             "wardrik.tool_call.progress"
           ]
  end

  test "reads the same schemas from its files as it compiled in" do
    for name <- ["cloudevent", "defs", "run.interrupted", "message.completed"] do
      assert WardrikProtocol.Inline.schema(WardrikProtocol.dir(), name) ==
               WardrikProtocol.schema(name)
    end
  end

  test "has its files where it says, and needs no recompiling while they stay" do
    refute WardrikProtocol.__mix_recompile__?()
    assert File.exists?(Path.join(WardrikProtocol.dir(), "cloudevent.json"))
  end
end
