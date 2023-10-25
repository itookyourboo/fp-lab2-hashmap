defmodule HashMapTest do
  use ExUnit.Case
  doctest HashMap

  test "Test get by key" do
    hm = HashMap.new()
      |> HashMap.add("key1", "value1")
      |> HashMap.add("key2", "value2")
      |> HashMap.add("key3", "value3")

    assert HashMap.get(hm, "key2") == "value2"
  end

  test "Test get by undeclared key" do
    hm = HashMap.new()
      |> HashMap.add("key1", "value1")

    assert HashMap.get(hm, "key2") == nil
  end

  test "Test get by key with collision" do
    hm = HashMap.new(2)
      |> HashMap.add("key1", "value1")
      |> HashMap.add("key2", "value2")
      |> HashMap.add("key3", "value3")

    assert HashMap.get(hm, "key1") == "value1"
    assert HashMap.get(hm, "key2") == "value2"
    assert HashMap.get(hm, "key3") == "value3"
  end
end
