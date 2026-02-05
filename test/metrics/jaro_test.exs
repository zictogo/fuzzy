defmodule Metrics.JaroTest do
  use ExUnit.Case, async: true
  alias Metrics.Jaro

  describe "similarity/2" do
    test "identical strings" do
      assert Jaro.similarity("hello", "hello") == 1.0
      assert Jaro.similarity("", "") == 1.0
    end

    test "empty strings" do
      assert Jaro.similarity("hello", "") == 0.0
      assert Jaro.similarity("", "hello") == 0.0
    end

    test "completely different strings" do
      assert Jaro.similarity("abc", "xyz") == 0.0
    end

    test "is symmetric" do
      assert Jaro.similarity("martha", "marhta") == Jaro.similarity("marhta", "martha")
    end

    test "classic examples" do
      assert_in_delta Jaro.similarity("dwayne", "duane"), 0.822, 0.001
      assert_in_delta Jaro.similarity("martha", "marhta"), 0.944, 0.001
      assert_in_delta Jaro.similarity("jones", "johnson"), 0.790, 0.001
    end

    test "handles unicode" do
      assert Jaro.similarity("café", "café") == 1.0
      assert_in_delta Jaro.similarity("café", "cafe"), 0.833, 0.001
      assert Jaro.similarity("naïve", "naïve") == 1.0
      assert_in_delta Jaro.similarity("naïve", "naive"), 0.866, 0.001
      assert Jaro.similarity("日本語", "日本語") == 1.0
      assert_in_delta Jaro.similarity("日本語", "日本"), 0.888, 0.001
      assert Jaro.similarity("👋🌍", "👋🌍") == 1.0
      assert_in_delta Jaro.similarity("👋🌍", "👋🌎"), 0.666, 0.001
    end

    test "single character strings" do
      assert Jaro.similarity("a", "a") == 1.0
      assert Jaro.similarity("a", "b") == 0.0
    end

    test "overlapping strings" do
      assert_in_delta Jaro.similarity("abcd", "bcde"), 0.833, 0.001
    end

    test "handles repeated characters" do
      assert_in_delta Jaro.similarity("aaab", "abaa"), 0.833, 0.001
    end

    test "other examples" do
      assert_in_delta Jaro.similarity("paper", "taper"), 0.866, 0.001
      assert_in_delta Jaro.similarity("kitten", "sitting"), 0.746, 0.001
      assert_in_delta Jaro.similarity("hello", "h"), 0.733, 0.001
      assert_in_delta Jaro.similarity("martha", "mxrhta"), 0.822, 0.001
      assert_in_delta Jaro.similarity("hello", "hallo"), 0.866, 0.001
      assert_in_delta Jaro.similarity("testABC", "testXYZ"), 0.714, 0.001
      assert_in_delta Jaro.similarity("testabABC", "testabXYZ"), 0.777, 0.001
    end

    test "longer strings" do
      s1 = "private Thread currentThread;"
      s2 = "private volatile Thread currentThread;"
      assert_in_delta Jaro.similarity(s1, s2), 0.811, 0.001
    end
  end
end
