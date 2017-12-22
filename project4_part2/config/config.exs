# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :project4_part2, Project4Part2Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "hkr+8dRE+2wqenjj5EA8UqY1tFFbS5iOOMZh04wOCync5C9H8L66LPWrRYskyUPO",
  render_errors: [view: Project4Part2Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Project4Part2.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
