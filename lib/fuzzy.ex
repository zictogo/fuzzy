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

  @doc """
  Find the best partial match between two strings.
  """
  @spec partial_ratio(String.t(), String.t()) :: float()
  def partial_ratio(s, s), do: 1.00
  def partial_ratio("", _), do: 1.00
  def partial_ratio(_, ""), do: 1.00

  def partial_ratio(s1, s2) do
    {short, long} =
      if String.length(s1) > String.length(s2), do: {s2, s1}, else: {s1, s2}

    short_length = String.length(short)
    long_length = String.length(long)

    if short_length == long_length do
      ratio(short, long)
    else
      long_graphemes = String.graphemes(long)

      0..(long_length - short_length)
      |> Enum.map(fn start ->
        window =
          long_graphemes
          |> Enum.slice(start, short_length)
          |> Enum.join()

        ratio(short, window)
      end)
      |> Enum.max(fn -> 0.00 end)
    end
  end
end
