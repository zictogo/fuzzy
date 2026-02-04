defmodule Metrics.JaroWinkler do
  @moduledoc """
  This module calculates Jaro-Winkler similarity between two strings.
  """
  alias Metrics.Jaro

  @spec similarity(String.t(), String.t(), keyword()) :: float()
  def similarity(s1, s2, opts \\ [])

  def similarity(s, s, _), do: 1.0
  def similarity("", _, _), do: 0.0
  def similarity(_, "", _), do: 0.0

  def similarity(s1, s2, opts) do
    prefix_weight = Keyword.get(opts, :prefix_weight, 0.1)
    max_prefix_length = Keyword.get(opts, :prefix_length, 4)

    jaro_similarity = Jaro.similarity(s1, s2)

    if jaro_similarity == 0.0 do
      0.0
    else
      prefix_length =
        Enum.zip(String.graphemes(s1), String.graphemes(s2))
        |> Enum.take_while(fn {a, b} -> a == b end)
        |> length
        |> min(max_prefix_length)

      # Jaro-Winkler formula: boost based on common prefix
      jaro_similarity + prefix_length * prefix_weight * (1 - jaro_similarity)
    end
  end
end
