defmodule JsonSchema.Mixfile do
  use Mix.Project

  def project do
    [
      app: :json_schema,
      version: "1.0.0",
      elixir: "~> 1.7",
      deps: deps(),
      aliases: aliases(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,

      # Dialyxir
      dialyzer: [plt_add_deps: :project],

      # Docs
      name: "JSON Schema",
      source_url: "https://github.com/dragonwasrobot/json_schema/",

      # Test coverage
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:credo, "~> 0.9.3", only: [:dev, :test]},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.19-rc", only: :dev, runtime: false},
      {:excoveralls, "~> 0.9.1", only: :test},
      {:poison, "~> 3.1"}
    ]
  end

  defp aliases do
    [
      build: ["deps.get", "compile"]
    ]
  end
end
