defmodule FuzzyTest do
  use ExUnit.Case
  doctest Fuzzy

  test "greets the world" do
    assert Fuzzy.hello() == :world
  end
end
