defmodule Wardrik.Channel do
  @moduledoc """
  A behaviour for chat apps, like Slack, that people reach agents through.

  Give each channel a name of your own in Wardrik's `:channels` option:

      channels: [slack: {WardrikSlack, token: token, signing_secret: secret}]

  Each channel runs under Wardrik's supervisor. Requests to `POST /v1/channels/{channel}/{path}`
  reach `c:request/2` unchanged, so the channel can verify them, for example by a signature over
  the body. To deliver one yourself:

      {:ok, answer} = Wardrik.Channel.deliver(scope,
        channel: "slack",
        path: "events",
        body: body,
        headers: headers
      )

  Every callback gets the channel's options, plus:

    * `:wardrik` - the instance the channel runs under.
    * `:channel` - the channel's name.
    * `:store` - Wardrik's store. Prefix keys with your package's name.
  """

  use Wardrik.Operations.Functions, prefix: "channel"

  @typedoc "A request from the chat app: its `path` within the channel, raw `body`, and `headers` by lowercase name."
  @type request() :: %{path: String.t(), body: String.t(), headers: %{String.t() => String.t()}}

  @typedoc "The response sent back to the chat app."
  @type response() :: %{
          status: pos_integer(),
          headers: %{String.t() => String.t()},
          body: String.t()
        }

  @doc "Returns the child spec the channel runs as."
  @callback child_spec(opts :: keyword()) :: Supervisor.child_spec()

  @doc "Handles a request from the chat app and returns the response."
  @callback request(request(), opts :: keyword()) :: response()

  @doc """
  Posts a `Wardrik.Channel.Notification`. Returns `{:skip, reason}` if there's nowhere to post.
  Optional: a channel without it posts no notices. See `Wardrik.Notify`.
  """
  @callback notify(Wardrik.Channel.Notification.t(), opts :: keyword()) ::
              :ok | {:skip, String.t()} | {:error, term()}

  @optional_callbacks notify: 2
end
