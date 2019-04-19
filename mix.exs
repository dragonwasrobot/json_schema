defmodule JsonSchema.Mixfile do
  use Mix.Project

  @version "0.2.0"
  @elixir_version "~> 1.8"

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
    [applications: [:logger]]
  end

  defp aliases do
    [build: ["deps.get", "compile"]]
  end

  defp deps do
    [
      {:credo, "~> 1.0.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.19-rc", only: :dev, runtime: false},
      {:excoveralls, "~> 0.9.1", only: :test},
      {:jason, "~> 1.1"},
      {:typed_struct, "~> 0.1.4"}
    ]
  end

  defp description do
    """
    A library for parsing, inspecting and manipulating JSON Schema documents.
    """
  end

  defp dialyzer do
    [plt_add_deps: :project]
  end

  defp docs do
    [
      name: "JSON Schema",
      main: "getting-started",
      formatter_opts: [gfm: true],
      source_ref: @version,
      source_url: "https://github.com/dragonwasrobot/json_schema",
      extras: [
        "docs/getting-started.md",
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
