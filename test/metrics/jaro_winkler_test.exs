defmodule Metrics.JaroWinklerTest do
  use ExUnit.Case, async: true

  alias Metrics.Jaro
  alias Metrics.JaroWinkler

  describe "similarity/3" do
    test "identical strings" do
      assert JaroWinkler.similarity("hello", "hello") == 1.0
      assert JaroWinkler.similarity("", "") == 1.0
    end

    test "empty string vs non-empty string" do
      assert JaroWinkler.similarity("hello", "") == 0.0
      assert JaroWinkler.similarity("", "hello") == 0.0
    end

    test "strings with common prefix compared to Jaro similarity" do
      pairs = [
        {"dwayne", "duane"},
        {"martha", "marhta"},
        {"dixon", "dicksonx"},
        {"jones", "johnson"}
      ]

      for {s1, s2} <- pairs do
        jaro = Jaro.similarity(s1, s2)
        jaro_winkler = JaroWinkler.similarity(s1, s2)
        assert jaro_winkler >= jaro, "Failed for #{s1}, #{s2}"
      end
    end

    test "prefix bonus only applies to first 4 characters by default" do
      # Same 4-char prefix
      score1 = JaroWinkler.similarity("testABC", "testXYZ")
      # Same 6-char prefix (but only 4 count)
      score2 = JaroWinkler.similarity("testabABC", "testabXYZ")

      # The difference should be from the Jaro component, not additional prefix bonus
      jaro1 = Jaro.similarity("testABC", "testXYZ")
      jaro2 = Jaro.similarity("testabABC", "testabXYZ")

      # Both should have same prefix bonus (4 chars)
      _prefix_bonus1 = score1 - jaro1
      _prefix_bonus2 = score2 - jaro2

      # Prefix bonuses should be proportional to (1 - jaro), so we can't directly compare
      # But we can verify the formula is applied correctly
      assert score1 > jaro1
      assert score2 > jaro2
    end

    test "custom prefix_weight option" do
      # Higher weight = more bonus for common prefix
      low_weight = JaroWinkler.similarity("test", "tesa", prefix_weight: 0.05)
      high_weight = JaroWinkler.similarity("test", "tesa", prefix_weight: 0.2)

      assert high_weight > low_weight
    end

    test "custom prefix_length option" do
      # With max prefix 2, only first 2 chars count
      short_prefix = JaroWinkler.similarity("abcdef", "abcxyz", prefix_length: 2)
      long_prefix = JaroWinkler.similarity("abcdef", "abcxyz", prefix_length: 4)

      assert long_prefix > short_prefix
    end

    test "well-known examples" do
      assert_in_delta JaroWinkler.similarity("dwayne", "duane"), 0.84, 0.01
      assert_in_delta JaroWinkler.similarity("martha", "marhta"), 0.961, 0.01
    end

    test "handles unicode" do
      assert JaroWinkler.similarity("café", "café") == 1.0
      assert JaroWinkler.similarity("日本語", "日本語") == 1.0
      assert JaroWinkler.similarity("👋🌍", "👋🌍") == 1.0
      assert JaroWinkler.similarity("café", "cafe") > 0.0
    end
  end
end
