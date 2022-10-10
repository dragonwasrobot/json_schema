defmodule JsonSchema.MixProject do
  use Mix.Project

  @version "0.4.0"
  @elixir_version "~> 1.12"

  def project do
    [
      app: :json_schema,
      version: @version,
      elixir: @elixir_version,
      aliases: aliases(),
      deps: deps(),
      description: description(),
      dialyzer: dialyzer(),
      docs: docs(),
      package: package(),
      preferred_cli_env: preferred_cli_env(),
      test_coverage: test_coverage(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp aliases do
    [build: ["deps.get", "compile"]]
  end

  defp deps do
    [
      {:credo, "~> 1.6.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.2.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.28.3", only: :dev, runtime: false},
      {:excoveralls, "~> 0.15.0", only: :test},
      {:gradient, github: "esl/gradient", only: [:dev], runtime: false},
      {:jason, "~> 1.4.0"},
      {:typed_struct, "~> 0.3.0"}
    ]
  end

  defp description do
    """
    A library for parsing, inspecting and manipulating JSON Schema documents.
    """
  end

  defp dialyzer do
    [plt_add_deps: :apps_direct]
  end

  defp docs do
    [
      name: "JSON Schema",
      main: "readme",
      formatter_opts: [gfm: true],
      source_ref: @version,
      source_url: "https://github.com/dragonwasrobot/json_schema",
      extras: [
        "README.md",
        "CHANGELOG.md"
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Peter Urbak"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/dragonwasrobot/json_schema"}
    ]
  end

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ]
  end

  defp test_coverage do
    [tool: ExCoveralls]
  end
end
