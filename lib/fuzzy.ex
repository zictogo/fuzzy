defmodule Fuzzy do
  @moduledoc """
  Fuzzy string matching.

  ## Default Metric

  By default, all functions use Levenshtein distance.
  You can specify a different metric with the `:metric` option:

      # Using default (Levenshtein)
      Fuzzy.ratio("hello", "hallo")
      # => 80.0
      
      # Using Jaro-Winkler (better for names)
      Fuzzy.ratio("dwayne", "duane", metric: :jaro_winkler)
      # => 84.0

  ## Available Metrics

  - `:levenshtein` - Good general-purpose metric.
  - `:jaro` - Good for short strings.
  - `:jaro_winkler` - Best for names.

  """

  alias Similarity

  @type metric :: :levenshtein | :jaro | :jaro_winkler
  @default_metric :levenshtein

  @doc """
  Calculate similarity ratio between two strings.
  """
  @spec ratio(String.t(), String.t(), keyword()) :: float()
  def ratio(s1, s2, opts \\ [])

  def ratio(s, s, _), do: 1.0
  def ratio("", "", _), do: 1.0
  def ratio("", _, _), do: 0.0
  def ratio(_, "", _), do: 0.0

  def ratio(s1, s2, opts) do
    metric = Keyword.get(opts, :metric, @default_metric)
    similarity = Similarity.similarity(s1, s2, metric)
    Float.round(similarity, 2)
  end

  @doc """
  Find the best partial match between two strings.
  """
  @spec partial_ratio(String.t(), String.t(), keyword()) :: float()
  def partial_ratio(s1, s2, opts \\ [])

  def partial_ratio(s, s, _), do: 1.0
  def partial_ratio("", _, _), do: 1.0
  def partial_ratio(_, "", _), do: 1.0

  def partial_ratio(s1, s2, opts) do
    {short, long} =
      if String.length(s1) > String.length(s2), do: {s2, s1}, else: {s1, s2}

    short_length = String.length(short)
    long_length = String.length(long)

    if short_length == long_length do
      ratio(short, long, opts)
    else
      long_graphemes = String.graphemes(long)

      0..(long_length - short_length)
      |> Enum.map(fn start ->
        window =
          long_graphemes
          |> Enum.slice(start, short_length)
          |> Enum.join()

        ratio(short, window, opts)
      end)
      |> Enum.max(fn -> 0.00 end)
    end
  end

  @doc """
  Compare strings after sorting their tokens alphabetically.
  """
  @spec token_sort_ratio(String.t(), String.t(), keyword()) :: float()
  def token_sort_ratio(s1, s2, opts \\ []) do
    t1 = process_and_sort(s1)
    t2 = process_and_sort(s2)
    ratio(t1, t2, opts)
  end

  @doc """
  Compare strings using set operations on tokens.
  """
  @spec token_set_ratio(String.t(), String.t(), keyword()) :: float()
  def token_set_ratio(s1, s2, opts \\ []) do
    tokens1 = s1 |> process_string() |> String.split() |> MapSet.new()
    tokens2 = s2 |> process_string() |> String.split() |> MapSet.new()

    intersection = MapSet.intersection(tokens1, tokens2)
    diff1 = MapSet.difference(tokens1, tokens2)
    diff2 = MapSet.difference(tokens2, tokens1)

    sorted_intersection = intersection |> Enum.sort() |> Enum.join(" ")
    sorted_diff1 = diff1 |> Enum.sort() |> Enum.join(" ")
    sorted_diff2 = diff2 |> Enum.sort() |> Enum.join(" ")

    combined1 = String.trim("#{sorted_intersection} #{sorted_diff1}")
    combined2 = String.trim("#{sorted_intersection} #{sorted_diff2}")

    # returns the best of three comparisons
    [
      ratio(sorted_intersection, combined1, opts),
      ratio(sorted_intersection, combined2, opts),
      ratio(combined1, combined2, opts)
    ]
    |> Enum.max()
  end

  # -----------------------------------------------------------------
  # Helpers

  defp process_string(s) do
    s
    |> String.downcase()
    |> String.replace(~r/[^\p{L}\p{N}\s]/u, "")
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end

  defp process_and_sort(s) do
    s
    |> process_string()
    |> String.split()
    |> Enum.sort()
    |> Enum.join(" ")
  end
end
