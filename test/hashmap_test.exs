defmodule HashMapTest do
  use ExUnit.Case

  test "Test get by key" do
    hm =
      HashMap.new()
      |> HashMap.add("key1", "value1")
      |> HashMap.add("key2", "value2")
      |> HashMap.add("key3", "value3")

    assert HashMap.get(hm, "key2") == "value2"
  end

  test "Test get by undeclared key" do
    hm =
      HashMap.new()
      |> HashMap.add("key1", "value1")

    assert HashMap.get(hm, "key2") == nil
  end

  test "Test get by key with collision" do
    hm =
      HashMap.new(2)
      |> HashMap.add("key1", "value1")
      |> HashMap.add("key2", "value2")
      |> HashMap.add("key3", "value3")

    assert HashMap.get(hm, "key1") == "value1"
    assert HashMap.get(hm, "key2") == "value2"
    assert HashMap.get(hm, "key3") == "value3"
  end

  test "Test pop key" do
    hm =
      HashMap.new()
      |> HashMap.add("key1", "value1")

    assert HashMap.get(hm, "key1") == "value1"

    hm =
      hm
      |> HashMap.pop("key1")

    assert HashMap.get(hm, "key1") == nil
  end

  test "Test map" do
    hm =
      HashMap.new(2)
      |> HashMap.add("key1", "value1")
      |> HashMap.add("key2", "value2")
      |> HashMap.add("key3", "value3")

    result = HashMap.map(hm, fn {key, value} -> "#{key}_#{value}" end)
    assert result == ["key3_value3", "key2_value2", "key1_value1"]
  end

  test "Test foldl" do
    hm =
      HashMap.new(2)
      |> HashMap.add(1, 1)
      |> HashMap.add(2, 4)
      |> HashMap.add(3, 9)

    result =
      HashMap.foldl(hm, {1, 0}, fn {key1, value1}, {key2, value2} ->
        {key1 * key2, value1 + value2}
      end)

    assert result == {6, 14}
  end

  test "Test foldr" do
    hm =
      HashMap.new(2)
      |> HashMap.add(1, 1)
      |> HashMap.add(2, 4)
      |> HashMap.add(3, 9)

    result =
      HashMap.foldr(hm, {1, 0}, fn {key1, value1}, {key2, value2} ->
        {key1 * key2, value1 - value2}
      end)

    assert result == {6, 12}
  end

  test "Test filter" do
    hm =
      HashMap.new(2)
      |> HashMap.add(1, 1)
      |> HashMap.add(2, 4)
      |> HashMap.add(3, 9)

    result = HashMap.filter(hm, fn {k, _v} -> rem(k, 2) == 1 end)
    assert result == HashMap.pop(hm, 2)
  end
end
