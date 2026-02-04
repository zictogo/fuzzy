defmodule Fuzzy do
  @moduledoc """
  Fuzzy string matching.
  """

  alias Fuzzy.Distance

  @doc """
  Calculate similarity ratio between two strings.
  """
  @spec ratio(String.t(), String.t()) :: float()
  def ratio(s, s), do: 1.00
  def ratio("", ""), do: 1.00
  def ratio("", _), do: 0.00
  def ratio(_, ""), do: 0.00

  def ratio(s1, s2) do
    distance = Distance.levenshtein(s1, s2)
    max_length = max(String.length(s1), String.length(s2))
    similarity = 1 - distance / max_length
    Float.round(similarity, 2)
  end
end
