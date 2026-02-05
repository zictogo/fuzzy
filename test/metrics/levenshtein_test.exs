defmodule Metrics.LevenshteinTest do
  use ExUnit.Case, async: true
  alias Metrics.Levenshtein

  describe "similarity/3" do
    test "identical strings" do
      assert Levenshtein.similarity("hello", "hello", scaling: :sum_lengths) == 1.0
      assert Levenshtein.similarity("hello", "hello", scaling: :max_length) == 1.0
      assert Levenshtein.similarity("", "", scaling: :sum_lengths) == 1.0
      assert Levenshtein.similarity("", "", scaling: :max_length) == 1.0
    end

    test "empty strings" do
      assert Levenshtein.similarity("hello", "", scaling: :sum_lengths) == 0.0
      assert Levenshtein.similarity("hello", "", scaling: :max_length) == 0.0
      assert Levenshtein.similarity("", "hello", scaling: :sum_lengths) == 0.0
      assert Levenshtein.similarity("", "hello", scaling: :max_length) == 0.0
    end

    test "completely different strings" do
      assert Levenshtein.similarity("abc", "xyz", scaling: :sum_lengths) == 0.5
      assert Levenshtein.similarity("abc", "xyz", scaling: :max_length) == 0.0
    end

    test "is symmetric" do
      assert Levenshtein.similarity("martha", "marhta", scaling: :sum_lengths) ==
               Levenshtein.similarity("marhta", "martha", scaling: :sum_lengths)

      assert Levenshtein.similarity("martha", "marhta", scaling: :max_length) ==
               Levenshtein.similarity("marhta", "martha", scaling: :max_length)
    end

    test "classic examples" do
      assert_in_delta Levenshtein.similarity("dwayne", "duane", scaling: :sum_lengths),
                      0.818,
                      0.001

      assert_in_delta Levenshtein.similarity("dwayne", "duane", scaling: :max_length),
                      0.666,
                      0.001

      assert_in_delta Levenshtein.similarity("martha", "marhta", scaling: :sum_lengths),
                      0.833,
                      0.001

      assert_in_delta Levenshtein.similarity("martha", "marhta", scaling: :max_length),
                      0.666,
                      0.001

      assert_in_delta Levenshtein.similarity("jones", "johnson", scaling: :sum_lengths),
                      0.666,
                      0.001

      assert_in_delta Levenshtein.similarity("jones", "johnson", scaling: :max_length),
                      0.428,
                      0.001
    end

    test "handles unicode" do
      assert Levenshtein.similarity("café", "café", scaling: :sum_lengths) == 1.0
      assert Levenshtein.similarity("café", "café", scaling: :max_length) == 1.0
      assert_in_delta Levenshtein.similarity("café", "cafe", scaling: :sum_lengths), 0.875, 0.001
      assert_in_delta Levenshtein.similarity("café", "cafe", scaling: :max_length), 0.750, 0.001
      assert Levenshtein.similarity("naïve", "naïve", scaling: :sum_lengths) == 1.0
      assert Levenshtein.similarity("naïve", "naïve", scaling: :max_length) == 1.0

      assert_in_delta Levenshtein.similarity("naïve", "naive", scaling: :sum_lengths),
                      0.900,
                      0.001

      assert_in_delta Levenshtein.similarity("naïve", "naive", scaling: :max_length), 0.800, 0.001
      assert Levenshtein.similarity("日本語", "日本語", scaling: :sum_lengths) == 1.0
      assert Levenshtein.similarity("日本語", "日本語", scaling: :max_length) == 1.0
      assert_in_delta Levenshtein.similarity("日本語", "日本", scaling: :sum_lengths), 0.800, 0.001
      assert_in_delta Levenshtein.similarity("日本語", "日本", scaling: :max_length), 0.666, 0.001
      assert Levenshtein.similarity("👋🌍", "👋🌍", scaling: :sum_lengths) == 1.0
      assert Levenshtein.similarity("👋🌍", "👋🌍", scaling: :max_length) == 1.0
      assert_in_delta Levenshtein.similarity("👋🌍", "👋🌎", scaling: :sum_lengths), 0.750, 0.001
      assert_in_delta Levenshtein.similarity("👋🌍", "👋🌎", scaling: :max_length), 0.500, 0.001
    end

    test "single character strings" do
      assert Levenshtein.similarity("a", "a", scaling: :sum_lengths) == 1.0
      assert Levenshtein.similarity("a", "a", scaling: :max_length) == 1.0
      assert Levenshtein.similarity("a", "b", scaling: :sum_lengths) == 0.5
      assert Levenshtein.similarity("a", "b", scaling: :max_length) == 0.0
    end

    test "overlapping strings" do
      assert_in_delta Levenshtein.similarity("abcd", "bcde", scaling: :sum_lengths), 0.750, 0.001
      assert_in_delta Levenshtein.similarity("abcd", "bcde", scaling: :max_length), 0.500, 0.001
    end

    test "handles repeated characters" do
      assert_in_delta Levenshtein.similarity("aaab", "abaa", scaling: :sum_lengths), 0.750, 0.001
      assert_in_delta Levenshtein.similarity("aaab", "abaa", scaling: :max_length), 0.500, 0.001
    end

    test "other examples" do
      assert_in_delta Levenshtein.similarity("paper", "taper", scaling: :sum_lengths),
                      0.900,
                      0.001

      assert_in_delta Levenshtein.similarity("paper", "taper", scaling: :max_length), 0.800, 0.001

      assert_in_delta Levenshtein.similarity("kitten", "sitting", scaling: :sum_lengths),
                      0.769,
                      0.001

      assert_in_delta Levenshtein.similarity("kitten", "sitting", scaling: :max_length),
                      0.571,
                      0.001

      assert_in_delta Levenshtein.similarity("hello", "h", scaling: :sum_lengths), 0.333, 0.001
      assert_in_delta Levenshtein.similarity("hello", "h", scaling: :max_length), 0.199, 0.001

      assert_in_delta Levenshtein.similarity("martha", "mxrhta", scaling: :sum_lengths),
                      0.750,
                      0.001

      assert_in_delta Levenshtein.similarity("martha", "mxrhta", scaling: :max_length),
                      0.500,
                      0.001

      assert_in_delta Levenshtein.similarity("hello", "hallo", scaling: :sum_lengths),
                      0.900,
                      0.001

      assert_in_delta Levenshtein.similarity("hello", "hallo", scaling: :max_length), 0.800, 0.001
    end

    test "longer strings" do
      s1 = "private Thread currentThread;"
      s2 = "private volatile Thread currentThread;"
      assert_in_delta Levenshtein.similarity(s1, s2, scaling: :sum_lengths), 0.865, 0.001
      assert_in_delta Levenshtein.similarity(s1, s2, scaling: :max_length), 0.763, 0.001
    end
  end
end
