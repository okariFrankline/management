# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :management,
  # Name of the entire application
  app_name: "Sotoo",
  ecto_repos: [Management.Repo],
  generators: [binary_id: true],
  bamboo_from_email: "okarifrankline5678@gmail.com"

# Configures the endpoint
config :management, ManagementWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "40j9vvKhQIsgVa9j8efUIkNtu5zr5c0ks4b489qCNWJZtI1SkOIRTWOHaoz/EaTo",
  render_errors: [view: ManagementWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Management.PubSub,
  live_view: [signing_salt: "zPl+EL3M"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# guardian configuration
config :management, Management.Authentication.Guardian,
  issuer: "writing",
  secret_key: "e1YbUhS4A1lcZOUKQU/RoXYTohYSroBPVG4oGQmukIxrIsKzkci1kKf940Z92eRb",
  verify_issuer: true

config :guardian, Guardian.DB,
  # Add your repository module
  repo: Management.Repo,
  # default
  schema_name: "guardian_tokens",
  # store all token types if not set
  # token_types: ["refresh_token"], => Commenting this line out allows for the storing of all session
  # default: 60 minutes
  sweep_interval: 60

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
