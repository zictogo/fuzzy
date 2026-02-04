defmodule Metrics.JaroTest do
  use ExUnit.Case, async: true
  alias Metrics.Jaro

  describe "similarity/2" do
    test "identical strings" do
      assert Jaro.similarity("hello", "hello") == 1.0
      assert Jaro.similarity("", "") == 1.0
    end

    test "empty string vs non-empty string" do
      assert Jaro.similarity("hello", "") == 0.0
      assert Jaro.similarity("", "hello") == 0.0
    end

    test "completely different strings" do
      assert Jaro.similarity("abc", "xyz") == 0.0
    end

    test "is symmetric" do
      assert Jaro.similarity("dwayne", "duane") == Jaro.similarity("duane", "dwayne")
      assert Jaro.similarity("martha", "marhta") == Jaro.similarity("marhta", "martha")
    end

    test "classic examples" do
      assert_in_delta Jaro.similarity("dwayne", "duane"), 0.822, 0.001
      assert_in_delta Jaro.similarity("martha", "marhta"), 0.944, 0.001
      assert_in_delta Jaro.similarity("jones", "johnson"), 0.790, 0.001
    end

    test "transpositions are counted correctly" do
      assert Jaro.similarity("martha", "marhta") > Jaro.similarity("martha", "mxrhta")
    end

    test "handles unicode" do
      assert Jaro.similarity("café", "café") == 1.0
      assert Jaro.similarity("日本語", "日本語") == 1.0
      assert Jaro.similarity("👋🌍", "👋🌍") == 1.0
      assert Jaro.similarity("café", "cafe") > 0.0
      assert Jaro.similarity("naïve", "naive") > 0.0
    end

    test "single character strings" do
      assert Jaro.similarity("a", "a") == 1.0
      assert Jaro.similarity("a", "b") == 0.0
    end
  end
end
