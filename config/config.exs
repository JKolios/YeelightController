# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :yeelightUI, YeelightUIWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9cRKCb2+Xzu1JUevAySd+z2lMxQoAGPg7f4+SyGLoHxRdneOOqWbT4lQdlqFFOcN",
  render_errors: [view: YeelightUIWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: YeelightUI.PubSub,
  live_view: [signing_salt: "3Gqk4H1e"],
  discoveryMessageSendInterval: 300000

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
