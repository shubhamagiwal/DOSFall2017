defmodule GexampleTest do
  use ExUnit.Case
  doctest Gexample

  test "greets the world" do
    assert Gexample.hello() == :world
  end
end
