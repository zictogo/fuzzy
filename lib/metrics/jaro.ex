defmodule Metrics.Jaro do
  @moduledoc """
  This module calculates Jaro similarity between two strings.
  """
  @spec similarity(String.t(), String.t()) :: float()
  def similarity(s, s), do: 1.0
  def similarity("", _), do: 0.0
  def similarity(_, ""), do: 0.0

  def similarity(s1, s2) do
    # convert to graphemes for proper Unicode support
    g1 = String.graphemes(s1)
    g2 = String.graphemes(s2)

    length1 = length(g1)
    length2 = length(g2)

    match_window = max(div(max(length1, length2), 2) - 1, 0)

    {matches1, matched_indices2} = find_jaro_matches(g1, g2, match_window)
    match_count = length(matches1)

    if match_count == 0 do
      0.0
    else
      matches2 =
        matched_indices2
        |> Enum.sort()
        |> Enum.map(&Enum.at(g2, &1))

      transpositions = count_transpositions(matches1, matches2)

      m = match_count
      t = transpositions

      (m / length1 + m / length2 + (m - t / 2) / m) / 3
    end
  end

  defp find_jaro_matches(g1, g2, window) do
    length2 = length(g2)

    {matches, matched_indices} =
      g1
      |> Enum.with_index()
      |> Enum.reduce({[], MapSet.new()}, fn {char1, i}, {matches, matched} ->
        start_j = max(0, i - window)
        end_j = min(length2 - 1, i + window)

        case find_first_unmatched(char1, g2, start_j, end_j, matched) do
          {:found, j} -> {[char1 | matches], MapSet.put(matched, j)}
          :not_found -> {matches, matched}
        end
      end)

    {Enum.reverse(matches), matched_indices}
  end

  defp find_first_unmatched(char, g2, start_j, end_j, matched) do
    result =
      start_j..end_j//1
      |> Enum.find(fn j -> j not in matched and Enum.at(g2, j) == char end)

    if result, do: {:found, result}, else: :not_found
  end

  defp count_transpositions(matches1, matches2) do
    Enum.zip(matches1, matches2)
    |> Enum.count(fn {a, b} -> a != b end)
  end
end
