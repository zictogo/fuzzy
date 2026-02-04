defmodule FuzzyTest do
  use ExUnit.Case, async: true
  doctest Fuzzy

  describe "ratio/2" do
    test "identical strings" do
      assert Fuzzy.ratio("paper", "paper") == 1.00
      assert Fuzzy.ratio("test", "test") == 1.00
    end

    test "empty strings" do
      assert Fuzzy.ratio("", "") == 1.00
      assert Fuzzy.ratio("paper", "") == 0.00
      assert Fuzzy.ratio("", "paper") == 0.00
    end

    test "similar strings" do
      assert Fuzzy.ratio("paper", "taper") == 0.80
      assert Fuzzy.ratio("test", "tent") == 0.75
    end

    test "completely different strings" do
      assert Fuzzy.ratio("abc", "xyz") == 0.00
    end

    test "is symmetric" do
      assert Fuzzy.ratio("abc", "xyz") == Fuzzy.ratio("xyz", "abc")
      assert Fuzzy.ratio("paper", "taper") == Fuzzy.ratio("taper", "paper")
    end

    test "handles unicode" do
      assert Fuzzy.ratio("café", "cafe") == 0.75
      assert Fuzzy.ratio("naïve", "naive") == 0.80
      assert Fuzzy.ratio("日本語", "日本語") == 1.00
      assert Fuzzy.ratio("日本語", "日本") == 0.67
      assert Fuzzy.ratio("👋🌍", "👋🌎") == 0.50
    end

    test "with jaro metric" do
      assert_in_delta Fuzzy.ratio("dwayne", "duane", metric: :jaro), 0.82, 0.01
      assert Fuzzy.ratio("hello", "hello", metric: :jaro) == 1.0
    end

    test "with jaro_winkler metric" do
      assert_in_delta Fuzzy.ratio("dwayne", "duane", metric: :jaro_winkler), 0.84, 0.01
      assert Fuzzy.ratio("martha", "marhta", metric: :jaro_winkler) > Fuzzy.ratio("martha", "marhta", metric: :jaro)
    end
  end

  describe "partial_ratio/2" do
    test "identical strings" do
      assert Fuzzy.partial_ratio("paper", "paper") == 1.00
      assert Fuzzy.partial_ratio("test", "test") == 1.00
    end

    test "substring contained in string" do
      assert Fuzzy.partial_ratio("yankees", "new york yankees") == 1.00
      assert Fuzzy.partial_ratio("test", "this is a test") == 1.00
    end

    test "is symmetric" do
      assert Fuzzy.partial_ratio("new york yankees", "yankees") ==
               Fuzzy.partial_ratio("yankees", "new york yankees")

      assert Fuzzy.partial_ratio("test", "this is a test") ==
               Fuzzy.partial_ratio("this is a test", "test")
    end

    test "empty strings" do
      assert Fuzzy.partial_ratio("", "") == 1.00
      assert Fuzzy.partial_ratio("paper", "") == 1.00
      assert Fuzzy.partial_ratio("", "paper") == 1.00
    end

    test "partial ratio is higher than ratio" do
      partial = Fuzzy.partial_ratio("yankees", "new york yankees")
      full = Fuzzy.ratio("yankees", "new york yankees")
      assert partial > full
    end
  end

  describe "token_sort_ratio/2" do
    test "handles different word order" do
      assert Fuzzy.token_sort_ratio("fuzzy wuzzy was a bear", "wuzzy fuzzy was a bear") == 1.00
      assert Fuzzy.token_sort_ratio("New York Mets", "Mets New York") == 1.00
    end

    test "is case insensitive" do
      assert Fuzzy.token_sort_ratio("Hello World", "world hello") == 1.00
    end

    test "ignores punctuation" do
      assert Fuzzy.token_sort_ratio("hello, world!", "world hello") == 1.00
      assert Fuzzy.token_sort_ratio("test: one two", "two one test") == 1.00
    end

    test "handles extra whitespace" do
      assert Fuzzy.token_sort_ratio("hello   world", "world  hello") == 1.00
    end

    test "empty strings" do
      assert Fuzzy.token_sort_ratio("", "") == 1.0
      assert Fuzzy.token_sort_ratio("hello", "") == 0.0
    end

    test "with different metrics" do
      score_lev = Fuzzy.token_sort_ratio("hello world", "world hello", metric: :levenshtein)
      score_jaro = Fuzzy.token_sort_ratio("hello world", "world hello", metric: :jaro)
      assert score_lev == 1.0
      assert score_jaro == 1.0
    end
  end

  describe "token_set_ratio/2" do
    test "handle duplicate words" do
      assert Fuzzy.token_set_ratio("fuzzy was a bear", "fuzzy fuzzy was a bear") == 1.00
    end

    test "handles extra words gracefully" do
      score =
        Fuzzy.token_set_ratio("mariners vs angels", "los angeles angels at seattle mariners")

      assert score >= 0.80
    end

    test "identical sets of words" do
      assert Fuzzy.token_set_ratio("hello world", "world hello") == 1.00
    end

    test "completely different words" do
      score = Fuzzy.token_set_ratio("abc def", "xyz uvw")
      assert score < 0.50
    end

    test "empty strings" do
      assert Fuzzy.token_set_ratio("", "") == 1.0
    end

    test "with different metrics" do
      score = Fuzzy.token_set_ratio("hello world", "world hello", metric: :jaro_winkler)
      assert score == 1.0
    end
  end
end
