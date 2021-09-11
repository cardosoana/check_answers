# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :check_answers, CheckAnswersWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "1pCdwGeF2gYkybLaDxNan7SyupefZpUzlIbNeHKl+d3ySCyYdBgZCxPoqctcZFi2",
  render_errors: [view: CheckAnswersWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CheckAnswers.PubSub,
  live_view: [signing_salt: "WqlRUn80"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :check_answers, :root_path, File.cwd!()

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
