defmodule Fuzzy.MixProject do
  use Mix.Project

  @name "Fuzzy"
  @version "0.1.0"
  @source_url "https://github.com/zictogo/fuzzy"

  def project do
    [
      app: :fuzzy,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: @name,
      source_url: @source_url,
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp description do
    """
    Fuzzy string matching : find similar strings, detect typos, and match user input against known values.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      maintainers: ["zictogo"],
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG.md)
    ]
  end

  defp docs do
    [
      main: @name,
      extras: ["README.md", "CHANGELOG.md"],
      groups_for_modules: [
        Core: [Fuzzy, Similarity],
        Metrics: [Metrics.Levenshtein, Metrics.Jaro, Metrics.JaroWinkler]
      ]
    ]
  end
end
