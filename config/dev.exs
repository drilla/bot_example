use Mix.Config
# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :tlgm_bot,
  show_msg_log: true
