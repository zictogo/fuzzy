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

  @spec similarity(String.t(), String.t(), metric()) :: float()
  def similarity(s1, s2, metric \\ :levenshtein)

  def similarity(s, s, _metric), do: 1.0
  def similarity("", "", _metric), do: 1.0
  def similarity("", _, _metric), do: 0.0
  def similarity(_, "", _metric), do: 0.0

  def similarity(s1, s2, :levenshtein) do
    distance = Levenshtein.distance(s1, s2)
    max_length = max(String.length(s1), String.length(s2))
    1.0 - distance / max_length
  end

  def similarity(s1, s2, :jaro), do: Jaro.similarity(s1, s2)
  def similarity(s1, s2, :jaro_winkler), do: JaroWinkler.similarity(s1, s2)
end
