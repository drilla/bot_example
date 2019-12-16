# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :tlgm_bot,
  workers_count: 10,
  menu_path: "config/menu.exs",
  short_map_path: "config/short_map.exs",
 
  cache_update_frequency: 10, # minutes
  time_between_requests: 5000, #msec
  dets_dir: "dets",
  telegram_api_module: TlgmBot.Services.Telegram.Api,
  minblago_api_module: MinBlagoBot.Services.MinBlago.Api


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :logger,
  backends: [:console, {LoggerFileBackend, :error_log}],
  format: "$date [$time] [$node] $metadata[$level] $message\n"
 # handle_otp_reports: true,
 # handle_sasl_reports: true

config :logger, :error_log,
  path: "logs/last_elixir_dbg.log",
  level: :debug,
  format: "$date [$time] [$node] $metadata[$level] $message\n"

config :number, delimit: [
  precision: 0,
  delimiter: " ",
  separator: "."
]

config :number, percentage: [
  precision: 0,
  delimiter: " ",
  separator: "."
]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
import_config("all.secret.exs")
import_config("#{Mix.env()}.secret.exs")
