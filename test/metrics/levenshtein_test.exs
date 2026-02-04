defmodule Metrics.LevenshteinTest do
  use ExUnit.Case, async: true
  alias Metrics.Levenshtein

  describe "distance/2" do
    test "identical strings" do
      assert Levenshtein.distance("paper", "paper") == 0
      assert Levenshtein.distance("z", "z") == 0
      assert Levenshtein.distance("", "") == 0
    end

    test "empty string vs non-empty string" do
      assert Levenshtein.distance("paper", "") == 5
      assert Levenshtein.distance("", "paper") == 5
      assert Levenshtein.distance("z", "") == 1
    end

    test "single character difference" do
      assert Levenshtein.distance("paper", "taper") == 1
      assert Levenshtein.distance("paper", "pape") == 1
      assert Levenshtein.distance("paper", "papers") == 1
    end

    test "classic examples" do
      assert Levenshtein.distance("kitten", "sitting") == 3
      assert Levenshtein.distance("saturday", "sunday") == 3
      assert Levenshtein.distance("book", "back") == 2
    end

    test "is symmetric" do
      assert Levenshtein.distance("abc", "xyz") == Levenshtein.distance("xyz", "abc")
      assert Levenshtein.distance("paper", "taper") == Levenshtein.distance("taper", "paper")
    end

    test "handles unicode" do
      assert Levenshtein.distance("café", "cafe") == 1
      assert Levenshtein.distance("naïve", "naive") == 1
      assert Levenshtein.distance("日本語", "日本語") == 0
      assert Levenshtein.distance("日本語", "日本") == 1
      assert Levenshtein.distance("🌎🌍", "🌎🌍") == 0
      assert Levenshtein.distance("👋🌍", "👋🌎") == 1
    end

    test "handles long strings" do
      s1 = String.duplicate("a", 100)
      s2 = String.duplicate("b", 100)
      assert Levenshtein.distance(s1, s2) == 100

      s3 = String.duplicate("a", 100)
      s4 = String.duplicate("a", 99) <> "b"
      assert Levenshtein.distance(s3, s4) == 1
    end
  end
end
