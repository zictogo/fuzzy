defmodule Similarity do
  @moduledoc """
  This module provides multiple algorithms for measuring how similar two strings are.
  Each returns a normalized score from 0.0 to 1.0.

  ## Available Metrics

  - `:levenshtein` - Good general-purpose metric.
  - `:jaro` - Good for short strings.
  - `:jaro_winkler` - Best for names.

  """

  alias Metrics.Levenshtein
  alias Metrics.Jaro
  alias Metrics.JaroWinkler

  @type metric :: :levenshtein | :jaro | :jaro_winkler

  @spec similarity(String.t(), String.t(), keyword()) :: float()
  def similarity(s1, s2, opts \\ [])

  def similarity(s, s, _opts), do: 1.0
  def similarity("", "", _opts), do: 1.0
  def similarity("", _, _opts), do: 0.0
  def similarity(_, "", _opts), do: 0.0

  def similarity(s1, s2, opts) do
    metric = Keyword.get(opts, :metric, :levenshtein)

    case metric do
      :levenshtein ->
        distance = Levenshtein.distance(s1, s2)
        max_length = max(String.length(s1), String.length(s2))
        1.0 - distance / max_length

      :jaro ->
        Jaro.similarity(s1, s2)

      :jaro_winkler ->
        JaroWinkler.similarity(s1, s2, opts)
    end
  end
end
