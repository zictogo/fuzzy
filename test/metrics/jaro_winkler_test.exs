defmodule Metrics.JaroWinklerTest do
  use ExUnit.Case, async: true

  alias Metrics.JaroWinkler

  describe "similarity/3" do
    test "identical strings" do
      assert JaroWinkler.similarity("hello", "hello") == 1.0
      assert JaroWinkler.similarity("", "") == 1.0
    end

    test "empty strings" do
      assert JaroWinkler.similarity("hello", "") == 0.0
      assert JaroWinkler.similarity("", "hello") == 0.0
    end

    test "completely different strings" do
      assert JaroWinkler.similarity("abc", "xyz") == 0.0
    end

    test "is symmetric" do
      assert JaroWinkler.similarity("martha", "marhta") ==
               JaroWinkler.similarity("marhta", "martha")
    end

    test "classic examples" do
      assert_in_delta JaroWinkler.similarity("dwayne", "duane"), 0.840, 0.001
      assert_in_delta JaroWinkler.similarity("martha", "marhta"), 0.961, 0.001
      assert_in_delta JaroWinkler.similarity("jones", "johnson"), 0.832, 0.001
      assert_in_delta JaroWinkler.similarity("dixon", "dicksonx"), 0.813, 0.001
    end

    test "handles unicode" do
      assert JaroWinkler.similarity("café", "café") == 1.0
      assert_in_delta JaroWinkler.similarity("café", "cafe"), 0.883, 0.001
      assert JaroWinkler.similarity("naïve", "naïve") == 1.0
      assert_in_delta JaroWinkler.similarity("naïve", "naive"), 0.893, 0.001
      assert JaroWinkler.similarity("日本語", "日本語") == 1.0
      assert_in_delta JaroWinkler.similarity("日本語", "日本"), 0.911, 0.001
      assert JaroWinkler.similarity("👋🌍", "👋🌍") == 1.0
      assert_in_delta JaroWinkler.similarity("👋🌍", "👋🌎"), 0.700, 0.001
    end

    test "single character strings" do
      assert JaroWinkler.similarity("a", "a") == 1.0
      assert JaroWinkler.similarity("a", "b") == 0.0
    end

    test "overlapping strings" do
      assert_in_delta JaroWinkler.similarity("abcd", "bcde"), 0.833, 0.001
    end

    test "handles repeated characters" do
      assert_in_delta JaroWinkler.similarity("aaab", "abaa"), 0.850, 0.001
    end

    test "other examples" do
      assert_in_delta JaroWinkler.similarity("paper", "taper"), 0.866, 0.001
      assert_in_delta JaroWinkler.similarity("kitten", "sitting"), 0.746, 0.001
      assert_in_delta JaroWinkler.similarity("hello", "h"), 0.760, 0.001
      assert_in_delta JaroWinkler.similarity("martha", "mxrhta"), 0.840, 0.001
      assert_in_delta JaroWinkler.similarity("hello", "hallo"), 0.880, 0.001
      assert_in_delta JaroWinkler.similarity("testABC", "testXYZ"), 0.828, 0.001
      assert_in_delta JaroWinkler.similarity("testabABC", "testabXYZ"), 0.866, 0.001
    end

    test "custom prefix_weight option" do
      assert_in_delta JaroWinkler.similarity("test", "tesa", prefix_weight: 0.05), 0.858, 0.001
      assert_in_delta JaroWinkler.similarity("test", "tesa", prefix_weight: 0.2), 0.933, 0.001
    end

    test "custom prefix_length option" do
      assert_in_delta JaroWinkler.similarity("abcdef", "abcxyz", prefix_length: 2), 0.733, 0.001
      assert_in_delta JaroWinkler.similarity("abcdef", "abcxyz", prefix_length: 4), 0.766, 0.001
    end
  end
end
