defmodule TlgmBot.Mixfile do
  use Mix.Project

  def project do
    [
      app: :tlgm_bot,
      version: "0.0.1",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {TlgmBot.Application, []},
      extra_applications: [:logger, :runtime_tools, :nadia, :timex]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/mock"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:gen_worker, ">= 0.0.1"},
      {:gettext, "~> 0.16.1"},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false},
      {:earmark, "~> 1.2", only: :dev},
      {:ecto_sql, "~> 3.0"},
      {:exprintf, "~> 0.2"},
      {:ex_doc, "~> 0.19", only: :dev},
      {:httpoison, "~> 1.5"},
      {:logger_file_backend, "~> 0.0.10"},
      {:myxql, ">= 0.0.0"},
      {:number, "~> 1.0.0"},
      {:nadia, "~> 0.5.0"},
      {:plug_cowboy, "~> 1.0"},
      {:poolboy, "~> 1.5.2"},
      {:poison, "~> 4.0"},
      {:scrivener_ecto, "~> 2.0"},
      {:timex, "~> 3.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
