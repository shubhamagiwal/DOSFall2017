defmodule ExamplemixTest do
  use ExUnit.Case
  doctest Examplemix

  test "greets the world" do
    assert Examplemix.hello() == :world
  end
end
