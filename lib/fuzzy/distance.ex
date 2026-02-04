defmodule Fuzzy.Distance do
  @moduledoc """
  String distance algorithms.
  """

  @spec levenshtein(String.t(), String.t()) :: non_neg_integer()
  def levenshtein(s, s), do: 0
  def levenshtein(s, ""), do: String.length(s)
  def levenshtein("", s), do: String.length(s)

  def levenshtein(s1, s2) do
    # convert to graphemes for proper Unicode support
    g1 = String.graphemes(s1)
    g2 = String.graphemes(s2)

    {g1, g2} =
      if length(g1) > length(g2) do
        {g2, g1}
      else
        {g1, g2}
      end

    # represents the cost of transforming "" to g1
    initial_row = Enum.to_list(0..length(g1))

    {final_row, _} =
      Enum.reduce(g2, {initial_row, 0}, fn char2, {previous_row, index} ->
        new_row = compute_row(g1, char2, previous_row, index + 1)
        {new_row, index + 1}
      end)

    # represents the cost of transforming g2 to g1
    List.last(final_row)
  end

  defp compute_row(g1, char2, previous_row, index) do
    initial = {[index], index - 1, 0}

    {row, _, _} =
      Enum.reduce(g1, initial, fn char1, {row, diagonal, col} ->
        above = Enum.at(previous_row, col + 1)
        left = hd(row)

        # if characters match cost is 0, if they don't cost is 1
        cost = if char1 == char2, do: 0, else: 1

        # take minimum of the 3 operations :
        # - substitute (diagonal + cost)
        # - delete (above + 1)
        # - insert (left + 1)
        cell = min(min(above + 1, left + 1), diagonal + cost)
        {[cell | row], Enum.at(previous_row, col + 1), col + 1}
      end)

    Enum.reverse(row)
  end
end
