defmodule Metrics.SequenceMatcher do
  @moduledoc """
  This module provides SequenceMatcher similarity calculations..
  Most users should use the higher-level functions in `Fuzzy` instead.

  ## Algorithm

  Uses the Ratcliff/Obershelp algorithm, it works by :

  1. Finding the longest contiguous matching subsequence (LCS)
  2. Recursively finding matching subsequences in the parts before and after
  3. Calculating similarity as: `2 * M / T`
     where M = total matching characters, T = total characters in both strings

  """

  @spec similarity(String.t(), String.t()) :: float()
  def similarity(s, s), do: 1.0
  def similarity("", _), do: 0.0
  def similarity(_, ""), do: 0.0

  def similarity(s1, s2) do
    g1 = String.graphemes(s1)
    g2 = String.graphemes(s2)
    matches = count_matching_characters(g1, g2)
    2 * matches / (length(g1) + length(g2))
  end

  defp count_matching_characters([], _), do: 0
  defp count_matching_characters(_, []), do: 0

  defp count_matching_characters(g1, g2) do
    case find_longest_match(g1, g2) do
      {_, _, 0} ->
        0

      {start1, start2, match_length} ->
        match_length +
          count_matching_characters(
            Enum.slice(g1, 0, start1),
            Enum.slice(g2, 0, start2)
          ) +
          count_matching_characters(
            Enum.slice(g1, (start1 + match_length)..-1//1),
            Enum.slice(g2, (start2 + match_length)..-1//1)
          )
    end
  end

  # Find the longest contiguous matching subsequence
  defp find_longest_match(g1, g2) do
    # Build a map of character positions in g2 for faster lookup
    g2_indices = build_index_map(g2)

    # For each position in g1, track the length of matches ending at each position in g2
    # We iterate through g1 and update match lengths
    {best, _} =
      g1
      |> Enum.with_index()
      |> Enum.reduce({{0, 0, 0}, %{}}, fn {char, i}, {best, prev_lengths} ->
        # Get all positions in g2 where this character appears
        j_positions = Map.get(g2_indices, char, [])

        # Update lengths for each position (must iterate in reverse to avoid conflicts)
        new_lengths =
          j_positions
          |> Enum.reduce(%{}, fn j, lengths ->
            # Length of match ending at (i, j) is 1 + length ending at (i-1, j-1)
            match_len = Map.get(prev_lengths, j - 1, 0) + 1
            Map.put(lengths, j, match_len)
          end)

        # Find the best match in this iteration
        new_best =
          Enum.reduce(new_lengths, best, fn {j, match_len}, {_, _, best_len} = current_best ->
            if match_len > best_len do
              # Start positions are current position minus match length plus 1
              {i - match_len + 1, j - match_len + 1, match_len}
            else
              current_best
            end
          end)

        {new_best, new_lengths}
      end)

    best
  end

  # Build a map from character to list of indices where it appears
  defp build_index_map(graphemes) do
    graphemes
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {char, index}, acc ->
      Map.update(acc, char, [index], &[index | &1])
    end)
  end
end
