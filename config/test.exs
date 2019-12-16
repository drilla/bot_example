use Mix.Config

config :tlgm_bot,
  telegram_api_module: Tests.Mock.TelegramApi,
  minblago_api_module: Tests.Mock.MinBlagoApi

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :tlgm_bot, TlgmBot.Repo,
  # username: "postgres",
  # password: "postgres",
  # database: "tlgm_bot_test",
  # hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

