use Mix.Config
# Do not print debug messages in production
config :logger, level: :error

# Finally import the config/prod.secret.exs
# which should be versioned separately.
