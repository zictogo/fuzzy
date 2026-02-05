defmodule Fuzzy do
  @moduledoc """
  Fuzzy string matching.

  ## Default Metric

  By default, all functions use the Sequence Matcher (Ratcliff/Obershelp algorithm).
  You can specify a different metric with the `:metric` option:

      # Using default (Sequence Matcher)
      Fuzzy.ratio("hello", "hallo")
      # => 0.8

      # Using Jaro-Winkler (better for names)
      Fuzzy.ratio("dwayne", "duane", metric: :jaro_winkler)
      # => 0.84

  ## Available Metrics

  - `:sequence_matcher` - Default. Ratcliff/Obershelp algorithm.
  - `:levenshtein` - Good general-purpose metric.
  - `:jaro` - Good for short strings.
  - `:jaro_winkler` - Best for names. Supports additional options:
    - `:prefix_weight` - Weight for common prefix bonus (default: 0.1)
    - `:prefix_length` - Maximum prefix length to consider (default: 4)

  """

  alias Similarity

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
    {normalize, opts} = Keyword.pop(opts, :normalize, false)
    s1 = normalize(s1, normalize)
    s2 = normalize(s2, normalize)

    similarity = Similarity.similarity(s1, s2, opts)
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
    {normalize, opts} = Keyword.pop(opts, :normalize, false)
    s1 = normalize(s1, normalize)
    s2 = normalize(s2, normalize)

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

  ## Options

  - `:ratio_fn` - The comparison function to use (`:ratio` or `:partial_ratio`).
  - `:metric` - The similarity metric to use. See module docs for available metrics.

  """
  @spec token_sort_ratio(String.t(), String.t(), keyword()) :: float()
  def token_sort_ratio(s1, s2, opts \\ [])

  def token_sort_ratio(s, s, _), do: 1.0
  def token_sort_ratio("", _, _), do: 0.0
  def token_sort_ratio(_, "", _), do: 0.0

  def token_sort_ratio(s1, s2, opts) do
    {ratio_fn, opts} = Keyword.pop(opts, :ratio_fn, :ratio)
    t1 = process_and_sort(s1)
    t2 = process_and_sort(s2)
    apply_ratio_fn(ratio_fn, t1, t2, opts)
  end

  @doc """
  Compares the intersection of tokens with each string's unique tokens,
  returning the best match. Handles duplicates and extra words gracefully.

  ## Options

  - `:ratio_fn` - The comparison function to use (`:ratio` or `:partial_ratio`).
  - `:metric` - The similarity metric to use. See module docs for available metrics.

  """
  @spec token_set_ratio(String.t(), String.t(), keyword()) :: float()
  def token_set_ratio(s1, s2, opts \\ [])

  def token_set_ratio(s, s, _), do: 1.0
  def token_set_ratio("", _, _), do: 0.0
  def token_set_ratio(_, "", _), do: 0.0

  def token_set_ratio(s1, s2, opts) do
    {ratio_fn, opts} = Keyword.pop(opts, :ratio_fn, :ratio)

    tokens1 = s1 |> normalize() |> String.split() |> MapSet.new()
    tokens2 = s2 |> normalize() |> String.split() |> MapSet.new()

    intersection = MapSet.intersection(tokens1, tokens2)
    diff1 = MapSet.difference(tokens1, intersection)
    diff2 = MapSet.difference(tokens2, intersection)

    sorted_intersection = intersection |> Enum.sort() |> Enum.join(" ")
    sorted_diff1 = diff1 |> Enum.sort() |> Enum.join(" ")
    sorted_diff2 = diff2 |> Enum.sort() |> Enum.join(" ")

    combined1 = String.trim("#{sorted_intersection} #{sorted_diff1}")
    combined2 = String.trim("#{sorted_intersection} #{sorted_diff2}")

    # returns the best of three comparisons
    [
      apply_ratio_fn(ratio_fn, sorted_intersection, combined1, opts),
      apply_ratio_fn(ratio_fn, sorted_intersection, combined2, opts),
      apply_ratio_fn(ratio_fn, combined1, combined2, opts)
    ]
    |> Enum.max()
  end

  # -----------------------------------------------------------------
  # Helpers

  @all_non_alpha_numeric ~r/[^\p{L}\p{N}]/u
  @non_alpha_numeric ~r/[^\p{L}\p{N}\s]/u
  @extra_spaces ~r/\s+/u

  def normalize(s, true) do
    s
    |> String.downcase()
    |> String.replace(@all_non_alpha_numeric, "")
  end

  def normalize(s, _), do: s

  def normalize(s) do
    s
    |> String.downcase()
    |> String.replace(@non_alpha_numeric, " ")
    |> String.replace(@extra_spaces, " ")
    |> String.trim()
  end

  defp process_and_sort(s) do
    s
    |> normalize()
    |> String.split()
    |> Enum.sort()
    |> Enum.join(" ")
  end

  defp apply_ratio_fn(:ratio, s1, s2, opts), do: ratio(s1, s2, opts)
  defp apply_ratio_fn(:partial_ratio, s1, s2, opts), do: partial_ratio(s1, s2, opts)
end
