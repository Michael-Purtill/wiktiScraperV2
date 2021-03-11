# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :wiktiScraperV2,
  ecto_repos: [WiktiScraperV2.Repo]

# Configures the endpoint
config :wiktiScraperV2, WiktiScraperV2Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nd8it9K+KLtBy/h95ihovO+hYC6nlsJi+U0WCSAQwU/yexOdsYFJeDo05OoLYu0q",
  render_errors: [view: WiktiScraperV2Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: WiktiScraperV2.PubSub,
  live_view: [signing_salt: "qlP/vIGv"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
