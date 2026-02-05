defmodule FuzzyTest do
  use ExUnit.Case, async: true
  doctest Fuzzy

  @metrics [:sequence_matcher, :levenshtein, :jaro, :jaro_winkler]

  describe "ratio/3" do
    test "identical strings" do
      for metric <- @metrics do
        assert Fuzzy.ratio("hello", "hello", metric: metric) == 1.0
        assert Fuzzy.ratio("", "", metric: metric) == 1.0
      end
    end

    test "empty strings" do
      for metric <- @metrics do
        assert Fuzzy.ratio("hello", "", metric: metric) == 0.0
        assert Fuzzy.ratio("", "hello", metric: metric) == 0.0
      end
    end

    test "completely different strings" do
      assert Fuzzy.ratio("abc", "xyz", metric: :levenshtein) == 0.5

      for metric <- [:sequence_matcher, :jaro, :jaro_winkler] do
        assert Fuzzy.ratio("abc", "xyz", metric: metric) == 0.0
      end
    end

    test "classic examples" do
      assert_in_delta Fuzzy.ratio("dwayne", "duane", metric: :sequence_matcher), 0.73, 0.01
      assert_in_delta Fuzzy.ratio("dwayne", "duane", metric: :levenshtein), 0.82, 0.01
      assert_in_delta Fuzzy.ratio("dwayne", "duane", metric: :jaro), 0.82, 0.01
      assert_in_delta Fuzzy.ratio("dwayne", "duane", metric: :jaro_winkler), 0.84, 0.01
      assert_in_delta Fuzzy.ratio("martha", "marhta", metric: :sequence_matcher), 0.83, 0.01
      assert_in_delta Fuzzy.ratio("martha", "marhta", metric: :levenshtein), 0.83, 0.01
      assert_in_delta Fuzzy.ratio("martha", "marhta", metric: :jaro), 0.94, 0.01
      assert_in_delta Fuzzy.ratio("martha", "marhta", metric: :jaro_winkler), 0.96, 0.01
      assert_in_delta Fuzzy.ratio("jones", "johnson", metric: :sequence_matcher), 0.67, 0.01
      assert_in_delta Fuzzy.ratio("jones", "johnson", metric: :levenshtein), 0.67, 0.01
      assert_in_delta Fuzzy.ratio("jones", "johnson", metric: :jaro), 0.79, 0.01
      assert_in_delta Fuzzy.ratio("jones", "johnson", metric: :jaro_winkler), 0.83, 0.01
    end

    test "custom normalize option" do
      for metric <- @metrics do
        assert Fuzzy.ratio("hello", "Hello !", normalize: true, metric: metric) == 1.0
        assert Fuzzy.ratio("👋🌍", "👋🌎", normalize: true, metric: metric) == 1.0
      end

      assert_in_delta Fuzzy.ratio("hello", "Hello !", normalize: false, metric: :sequence_matcher),
                      0.67,
                      0.01

      assert_in_delta Fuzzy.ratio("hello", "Hello !", normalize: false, metric: :levenshtein),
                      0.75,
                      0.01

      assert_in_delta Fuzzy.ratio("hello", "Hello !", normalize: false, metric: :jaro),
                      0.79,
                      0.01

      assert_in_delta Fuzzy.ratio("hello", "Hello !", normalize: false, metric: :jaro_winkler),
                      0.79,
                      0.01

      assert_in_delta Fuzzy.ratio("👋🌍", "👋🌎", normalize: false, metric: :sequence_matcher),
                      0.50,
                      0.01

      assert_in_delta Fuzzy.ratio("👋🌍", "👋🌎", normalize: false, metric: :levenshtein),
                      0.75,
                      0.01

      assert_in_delta Fuzzy.ratio("👋🌍", "👋🌎", normalize: false, metric: :jaro),
                      0.67,
                      0.01

      assert_in_delta Fuzzy.ratio("👋🌍", "👋🌎", normalize: false, metric: :jaro_winkler),
                      0.70,
                      0.01
    end
  end

  describe "partial_ratio/3" do
    test "identical strings" do
      for metric <- @metrics do
        assert Fuzzy.partial_ratio("hello", "hello", metric: metric) == 1.0
        assert Fuzzy.partial_ratio("", "", metric: metric) == 1.0
      end
    end

    test "empty strings" do
      for metric <- @metrics do
        assert Fuzzy.partial_ratio("hello", "", metric: metric) == 1.0
        assert Fuzzy.partial_ratio("", "hello", metric: metric) == 1.0
      end
    end

    test "substring contained in string" do
      for metric <- @metrics do
        assert Fuzzy.partial_ratio("yankees", "new york yankees", metric: metric) == 1.0
        assert Fuzzy.partial_ratio("test", "this is a test", metric: metric) == 1.0

        assert Fuzzy.partial_ratio("new york mets", "new york mets vs atlanta braves",
                 metric: metric
               ) == 1.0
      end
    end

    test "is symmetric" do
      for metric <- @metrics do
        assert Fuzzy.partial_ratio("new york yankees", "yankees", metric: metric) ==
                 Fuzzy.partial_ratio("yankees", "new york yankees", metric: metric)
      end
    end

    test "near matches with different metrics" do
      assert_in_delta Fuzzy.partial_ratio("new york mets", "new york metz",
                        metric: :sequence_matcher
                      ),
                      0.92,
                      0.01

      assert_in_delta Fuzzy.partial_ratio("new york mets", "new york metz", metric: :levenshtein),
                      0.96,
                      0.01

      assert_in_delta Fuzzy.partial_ratio("new york mets", "new york metz", metric: :jaro),
                      0.95,
                      0.01

      assert_in_delta Fuzzy.partial_ratio("new york mets", "new york metz", metric: :jaro_winkler),
                      0.97,
                      0.01

      assert_in_delta Fuzzy.partial_ratio("río grande", "rio grande", metric: :sequence_matcher),
                      0.90,
                      0.01

      assert_in_delta Fuzzy.partial_ratio("río grande", "rio grande", metric: :levenshtein),
                      0.95,
                      0.01

      assert_in_delta Fuzzy.partial_ratio("río grande", "rio grande", metric: :jaro),
                      0.93,
                      0.01

      assert_in_delta Fuzzy.partial_ratio("río grande", "rio grande", metric: :jaro_winkler),
                      0.94,
                      0.01
    end

    test "normalize option" do
      assert_in_delta Fuzzy.partial_ratio("Hello World", "hello, beautiful world!",
                        metric: :sequence_matcher,
                        normalize: true
                      ),
                      0.60,
                      0.01

      assert_in_delta Fuzzy.partial_ratio("Hello World", "hello, beautiful world!",
                        metric: :levenshtein,
                        normalize: true
                      ),
                      0.75,
                      0.01

      assert_in_delta Fuzzy.partial_ratio("Hello World", "hello, beautiful world!",
                        metric: :jaro,
                        normalize: true
                      ),
                      0.68,
                      0.01

      assert_in_delta Fuzzy.partial_ratio("Hello World", "hello, beautiful world!",
                        metric: :jaro_winkler,
                        normalize: true
                      ),
                      0.80,
                      0.01

      assert_in_delta Fuzzy.partial_ratio("Hello World", "hello, beautiful world!",
                        metric: :sequence_matcher,
                        normalize: false
                      ),
                      0.55,
                      0.01

      assert_in_delta Fuzzy.partial_ratio("Hello World", "hello, beautiful world!",
                        metric: :levenshtein,
                        normalize: false
                      ),
                      0.73,
                      0.01

      assert_in_delta Fuzzy.partial_ratio("Hello World", "hello, beautiful world!",
                        metric: :jaro,
                        normalize: false
                      ),
                      0.64,
                      0.01

      assert_in_delta Fuzzy.partial_ratio("Hello World", "hello, beautiful world!",
                        metric: :jaro_winkler,
                        normalize: false
                      ),
                      0.64,
                      0.01
    end

    test "jaro_winkler prefix options" do
      assert_in_delta Fuzzy.partial_ratio("new york mets", "new york metz", metric: :jaro_winkler),
                      0.97,
                      0.01

      assert_in_delta Fuzzy.partial_ratio("new york mets", "new york metz",
                        metric: :jaro_winkler,
                        prefix_weight: 0.2
                      ),
                      0.99,
                      0.01

      assert_in_delta Fuzzy.partial_ratio("new york mets", "new york metz",
                        metric: :jaro_winkler,
                        prefix_length: 2
                      ),
                      0.96,
                      0.01
    end

    test "levenshtein scaling option" do
      assert_in_delta Fuzzy.partial_ratio("new york mets", "new york metz", metric: :levenshtein),
                      0.96,
                      0.01

      assert_in_delta Fuzzy.partial_ratio("new york mets", "new york metz",
                        metric: :levenshtein,
                        scaling: :max_length
                      ),
                      0.92,
                      0.01
    end

    test "partial ratio is higher than ratio" do
      for metric <- @metrics do
        partial = Fuzzy.partial_ratio("yankees", "new york yankees", metric: metric)
        full = Fuzzy.ratio("yankees", "new york yankees", metric: metric)
        assert partial > full
      end
    end
  end

  describe "token_sort_ratio/3" do
    test "identical strings" do
      for metric <- @metrics do
        assert Fuzzy.token_sort_ratio("hello", "hello", metric: metric) == 1.0
        assert Fuzzy.token_sort_ratio("", "", metric: metric) == 1.0
      end
    end

    test "empty strings" do
      for metric <- @metrics do
        assert Fuzzy.token_sort_ratio("hello", "", metric: metric) == 0.0
        assert Fuzzy.token_sort_ratio("", "hello", metric: metric) == 0.0
      end
    end

    test "handles different word order with all metrics" do
      for metric <- @metrics do
        assert Fuzzy.token_sort_ratio("fuzzy wuzzy was a bear", "wuzzy fuzzy was a bear",
                 metric: metric
               ) == 1.0

        assert Fuzzy.token_sort_ratio("New York Mets", "Mets New York", metric: metric) == 1.0
      end
    end

    test "is case insensitive with all metrics" do
      for metric <- @metrics do
        assert Fuzzy.token_sort_ratio("Hello World", "world hello", metric: metric) == 1.0
      end
    end

    test "ignores punctuation with all metrics" do
      for metric <- @metrics do
        assert Fuzzy.token_sort_ratio("hello, world!", "world hello", metric: metric) == 1.0
        assert Fuzzy.token_sort_ratio("test: one two", "two one test", metric: metric) == 1.0
      end
    end

    test "handles extra whitespace" do
      for metric <- @metrics do
        assert Fuzzy.token_sort_ratio("hello   world", "world  hello", metric: metric) == 1.0
      end
    end

    test "near matches with different metrics" do
      assert_in_delta Fuzzy.token_sort_ratio("great new york mets", "new york mets really great",
                        metric: :sequence_matcher
                      ),
                      0.84,
                      0.01

      assert_in_delta Fuzzy.token_sort_ratio("great new york mets", "new york mets really great",
                        metric: :levenshtein
                      ),
                      0.84,
                      0.01

      assert_in_delta Fuzzy.token_sort_ratio("great new york mets", "new york mets really great",
                        metric: :jaro
                      ),
                      0.88,
                      0.01

      assert_in_delta Fuzzy.token_sort_ratio("great new york mets", "new york mets really great",
                        metric: :jaro_winkler
                      ),
                      0.93,
                      0.01
    end

    test "ratio_fn: :partial_ratio with all metrics" do
      for metric <- @metrics do
        assert Fuzzy.token_sort_ratio("def abc", "ghi def abc",
                 ratio_fn: :partial_ratio,
                 metric: metric
               ) == 1.0
      end
    end

    test "partial_ratio gives higher or equal score than ratio for substrings" do
      for metric <- @metrics do
        full =
          Fuzzy.token_sort_ratio("great new york mets", "new york mets really great",
            metric: metric
          )

        partial =
          Fuzzy.token_sort_ratio("great new york mets", "new york mets really great",
            ratio_fn: :partial_ratio,
            metric: metric
          )

        assert partial >= full
      end
    end

    test "jaro_winkler prefix options" do
      assert_in_delta Fuzzy.token_sort_ratio("great new york mets", "new york mets really great",
                        metric: :jaro_winkler
                      ),
                      0.93,
                      0.01

      assert_in_delta Fuzzy.token_sort_ratio("great new york mets", "new york mets really great",
                        metric: :jaro_winkler,
                        prefix_weight: 0.2
                      ),
                      0.98,
                      0.01
    end

    test "levenshtein scaling option" do
      assert_in_delta Fuzzy.token_sort_ratio("great new york mets", "new york mets really great",
                        metric: :levenshtein
                      ),
                      0.84,
                      0.01

      assert_in_delta Fuzzy.token_sort_ratio("great new york mets", "new york mets really great",
                        metric: :levenshtein,
                        scaling: :max_length
                      ),
                      0.73,
                      0.01
    end
  end

  describe "token_set_ratio/3" do
    test "identical sets of words with all metrics" do
      for metric <- @metrics do
        assert Fuzzy.token_set_ratio("hello world", "world hello", metric: metric) == 1.0
      end
    end

    test "empty strings" do
      assert Fuzzy.token_set_ratio("", "") == 1.0
    end

    test "handles extra words gracefully with all metrics" do
      for metric <- [:sequence_matcher, :levenshtein, :jaro, :jaro_winkler] do
        assert Fuzzy.token_set_ratio("fuzzy was a bear", "fuzzy fuzzy was a bear", metric: metric) ==
                 1.0

        assert Fuzzy.token_set_ratio(
                 "mariners vs angels",
                 "los angeles angels vs seattle mariners",
                 metric: metric
               ) == 1.0
      end
    end

    test "completely different words with different metrics" do
      assert Fuzzy.token_set_ratio("abc def", "xyz uvw", metric: :sequence_matcher) == 0.14

      assert_in_delta Fuzzy.token_set_ratio("abc def", "xyz uvw", metric: :levenshtein),
                      0.57,
                      0.01

      assert_in_delta Fuzzy.token_set_ratio("abc def", "xyz uvw", metric: :jaro), 0.43, 0.01

      assert_in_delta Fuzzy.token_set_ratio("abc def", "xyz uvw", metric: :jaro_winkler),
                      0.43,
                      0.01
    end

    test "overlapping tokens with different metrics" do
      assert_in_delta Fuzzy.token_set_ratio("fuzzy bear", "fuzzy was a beard indeed",
                        metric: :sequence_matcher
                      ),
                      0.67,
                      0.01

      assert_in_delta Fuzzy.token_set_ratio("fuzzy bear", "fuzzy was a beard indeed",
                        metric: :levenshtein
                      ),
                      0.67,
                      0.01

      assert_in_delta Fuzzy.token_set_ratio("fuzzy bear", "fuzzy was a beard indeed",
                        metric: :jaro
                      ),
                      0.83,
                      0.01

      assert_in_delta Fuzzy.token_set_ratio("fuzzy bear", "fuzzy was a beard indeed",
                        metric: :jaro_winkler
                      ),
                      0.90,
                      0.01
    end

    test "ratio_fn: :partial_ratio with all metrics" do
      for metric <- @metrics do
        assert Fuzzy.token_set_ratio("angels", "los angeles angels",
                 ratio_fn: :partial_ratio,
                 metric: metric
               ) == 1.0
      end
    end

    test "partial_ratio gives higher or equal score than ratio for substrings" do
      for metric <- @metrics do
        full =
          Fuzzy.token_set_ratio("fuzzy bear", "fuzzy was a beard indeed", metric: metric)

        partial =
          Fuzzy.token_set_ratio("fuzzy bear", "fuzzy was a beard indeed",
            ratio_fn: :partial_ratio,
            metric: metric
          )

        assert partial >= full
      end
    end

    test "levenshtein scaling option" do
      assert_in_delta Fuzzy.token_set_ratio("abc def", "xyz uvw", metric: :levenshtein),
                      0.57,
                      0.01

      assert Fuzzy.token_set_ratio("abc def", "xyz uvw",
               metric: :levenshtein,
               scaling: :max_length
             ) == 0.14
    end
  end
end
