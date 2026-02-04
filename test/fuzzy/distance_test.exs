defmodule Fuzzy.DistanceTest do
  use ExUnit.Case, async: true
  alias Fuzzy.Distance

  describe "levenshtein/2" do
    test "identical strings" do
      assert Distance.levenshtein("paper", "paper") == 0
      assert Distance.levenshtein("z", "z") == 0
      assert Distance.levenshtein("", "") == 0
    end

    test "empty string vs non-empty string" do
      assert Distance.levenshtein("paper", "") == 5
      assert Distance.levenshtein("", "paper") == 5
      assert Distance.levenshtein("z", "") == 1
    end

    test "single character difference" do
      assert Distance.levenshtein("paper", "taper") == 1
      assert Distance.levenshtein("paper", "pape") == 1
      assert Distance.levenshtein("paper", "papers") == 1
    end

    test "classic examples" do
      assert Distance.levenshtein("kitten", "sitting") == 3
      assert Distance.levenshtein("saturday", "sunday") == 3
      assert Distance.levenshtein("book", "back") == 2
    end

    test "is symmetric" do
      assert Distance.levenshtein("abc", "xyz") == Distance.levenshtein("xyz", "abc")
      assert Distance.levenshtein("paper", "taper") == Distance.levenshtein("taper", "paper")
    end

    test "handles unicode" do
      assert Distance.levenshtein("café", "cafe") == 1
      assert Distance.levenshtein("naïve", "naive") == 1
      assert Distance.levenshtein("日本語", "日本語") == 0
      assert Distance.levenshtein("日本語", "日本") == 1
      assert Distance.levenshtein("🌎🌍", "🌎🌍") == 0
      assert Distance.levenshtein("👋🌍", "👋🌎") == 1
    end

    test "handles long strings" do
      s1 = String.duplicate("a", 100)
      s2 = String.duplicate("b", 100)
      assert Distance.levenshtein(s1, s2) == 100

      s3 = String.duplicate("a", 100)
      s4 = String.duplicate("a", 99) <> "b"
      assert Distance.levenshtein(s3, s4) == 1
    end
  end
end
