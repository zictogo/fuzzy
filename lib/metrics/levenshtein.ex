defmodule Metrics.Levenshtein do
  @moduledoc """
  This module provides low-level Levenshtein distance calculations.
  Most users should use the higher-level functions in `Fuzzy` instead.

  ## Levenshtein Distance

  The Levenshtein distance between two strings is the minimum number of
  single-character edits (insertions, deletions, or substitutions) required
  to change one string into the other.

  ## Algorithm

  Uses the Wagner-Fischer algorithm with O(min(m,n)) space complexity.
  We only keep two rows of the matrix at a time, and we ensure the shorter
  string determines the row length.
  """

  @spec distance(String.t(), String.t()) :: non_neg_integer()
  def distance(s, s), do: 0
  def distance(s, ""), do: String.length(s)
  def distance("", s), do: String.length(s)

  def distance(s1, s2) do
    # convert to graphemes for proper Unicode support
    g1 = String.graphemes(s1)
    g2 = String.graphemes(s2)

    {g1, g2} = if length(g1) > length(g2), do: {g2, g1}, else: {g1, g2}

    # represents the cost of transforming "" to g1
    initial_row = Enum.to_list(0..length(g1))

    # represents the cost of transforming g2 to g1
    g2
    |> Enum.with_index(1)
    |> Enum.reduce(initial_row, fn {char2, row_index}, previous_row ->
      compute_row(g1, char2, previous_row, row_index)
    end)
    |> List.last()
  end

  defp compute_row(g1, char2, previous_row, row_index) do
    initial = {[row_index], Enum.at(previous_row, 0)}

    {row, _} =
      g1
      |> Enum.with_index(1)
      |> Enum.reduce(initial, fn {char1, col_index}, {row, diagonal} ->
        above = Enum.at(previous_row, col_index)
        left = hd(row)

        # if characters match cost is 0, if they don't cost is 1
        cost = if char1 == char2, do: 0, else: 1

        # take minimum of the 3 operations :
        # - substitute (diagonal + cost)
        # - delete (above + 1)
        # - insert (left + 1)
        cell = min(min(above + 1, left + 1), diagonal + cost)

        {[cell | row], above}
      end)

    Enum.reverse(row)
  end
end
