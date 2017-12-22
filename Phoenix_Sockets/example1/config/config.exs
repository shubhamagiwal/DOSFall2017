# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :example1, Example1Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Z2OWk3G0UgBbfnHe+Q+bX4vKyRUHNKvSUaVu5EoNAvzqHJMCZuqkEY+CC/2WD2Gz",
  render_errors: [view: Example1Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Example1.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
