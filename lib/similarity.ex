defmodule Similarity do
  @moduledoc """
  This module provides multiple algorithms for measuring how similar two strings are.
  Each returns a normalized score from 0.0 to 1.0.

  ## Available Metrics

  - `:sequence_matcher` - Default. Ratcliff/Obershelp algorithm.
  - `:levenshtein` - Good general-purpose metric.
  - `:jaro` - Good for short strings.
  - `:jaro_winkler` - Best for names.

  """

  alias Metrics.SequenceMatcher
  alias Metrics.Levenshtein
  alias Metrics.Jaro
  alias Metrics.JaroWinkler

  @type metric :: :sequence_matcher | :levenshtein | :jaro | :jaro_winkler

  @spec similarity(String.t(), String.t(), keyword()) :: float()
  def similarity(s1, s2, opts \\ [])

  def similarity(s, s, _opts), do: 1.0
  def similarity("", "", _opts), do: 1.0
  def similarity("", _, _opts), do: 0.0
  def similarity(_, "", _opts), do: 0.0

  def similarity(s1, s2, opts) do
    {metric, opts} = Keyword.pop(opts, :metric, :sequence_matcher)

    case metric do
      :sequence_matcher -> SequenceMatcher.similarity(s1, s2)
      :levenshtein -> Levenshtein.similarity(s1, s2, opts)
      :jaro -> Jaro.similarity(s1, s2)
      :jaro_winkler -> JaroWinkler.similarity(s1, s2, opts)
    end
  end
end
