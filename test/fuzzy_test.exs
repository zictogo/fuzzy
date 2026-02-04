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
  end
end
