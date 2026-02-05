defmodule Metrics.SequenceMatcherTest do
  use ExUnit.Case, async: true
  alias Metrics.SequenceMatcher

  describe "similarity/2" do
    test "identical strings" do
      assert SequenceMatcher.similarity("hello", "hello") == 1.0
      assert SequenceMatcher.similarity("", "") == 1.0
    end

    test "empty strings" do
      assert SequenceMatcher.similarity("hello", "") == 0.0
      assert SequenceMatcher.similarity("", "hello") == 0.0
    end

    test "completely different strings" do
      assert SequenceMatcher.similarity("abc", "xyz") == 0.0
    end

    test "is symmetric" do
      assert SequenceMatcher.similarity("martha", "marhta") ==
               SequenceMatcher.similarity("marhta", "martha")
    end

    test "classic examples" do
      assert_in_delta SequenceMatcher.similarity("dwayne", "duane"), 0.727, 0.001
      assert_in_delta SequenceMatcher.similarity("martha", "marhta"), 0.833, 0.001
      assert_in_delta SequenceMatcher.similarity("jones", "johnson"), 0.666, 0.001
    end

    test "handles unicode" do
      assert SequenceMatcher.similarity("café", "café") == 1.0
      assert_in_delta SequenceMatcher.similarity("café", "cafe"), 0.750, 0.001
      assert SequenceMatcher.similarity("naïve", "naïve") == 1.0
      assert_in_delta SequenceMatcher.similarity("naïve", "naive"), 0.800, 0.001
      assert SequenceMatcher.similarity("日本語", "日本語") == 1.0
      assert_in_delta SequenceMatcher.similarity("日本語", "日本"), 0.800, 0.001
      assert SequenceMatcher.similarity("👋🌍", "👋🌍") == 1.0
      assert_in_delta SequenceMatcher.similarity("👋🌍", "👋🌎"), 0.500, 0.001
    end

    test "single character strings" do
      assert SequenceMatcher.similarity("a", "a") == 1.0
      assert SequenceMatcher.similarity("a", "b") == 0.0
    end

    test "overlapping strings" do
      assert_in_delta SequenceMatcher.similarity("abcd", "bcde"), 0.750, 0.001
    end

    test "handles repeated characters" do
      assert_in_delta SequenceMatcher.similarity("aaab", "abaa"), 0.500, 0.001
    end

    test "other examples" do
      assert_in_delta SequenceMatcher.similarity("paper", "taper"), 0.800, 0.001
      assert_in_delta SequenceMatcher.similarity("kitten", "sitting"), 0.615, 0.001
      assert_in_delta SequenceMatcher.similarity("hello", "h"), 0.333, 0.001
      assert_in_delta SequenceMatcher.similarity("martha", "mxrhta"), 0.333, 0.001
      assert_in_delta SequenceMatcher.similarity("hello", "hallo"), 0.800, 0.001
    end

    test "longer strings" do
      s1 = "private Thread currentThread;"
      s2 = "private volatile Thread currentThread;"
      assert_in_delta SequenceMatcher.similarity(s1, s2), 0.865, 0.001
    end
  end
end
