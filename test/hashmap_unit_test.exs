defmodule HashMapUnitTest do
  use ExUnit.Case

  test "initialize empty map" do
    buckets_count = HashMap.default_buckets_count()

    assert %HashMap{buckets: [], buckets_count: ^buckets_count} = HashMap.new()
    assert %HashMap{buckets: [], buckets_count: 2} = HashMap.new(2)
  end

  test "raises when trying to initialize map with invalid buckets_count" do
    assert_raise FunctionClauseError, fn -> HashMap.new(0) end
  end

  test "put and get from has map" do
    hash_map = HashMap.new()

    refute HashMap.get(hash_map, "not_exists")

    hash_map =
      hash_map
      |> HashMap.put("some_key", 1)
      |> HashMap.put("some_key_2", 2)
      |> HashMap.put("some_key_2", 3)

    assert HashMap.get(hash_map, "some_key") == 1
    assert HashMap.get(hash_map, "some_key_2") == 3
  end

  test "remove/2" do
    empty_hash_map = HashMap.new()

    hash_map =
      empty_hash_map
      |> HashMap.put("key1", "value 1")
      |> HashMap.put("key2", "value 2")
      |> HashMap.remove("key1")

    refute HashMap.get(hash_map, "key1")
    assert HashMap.get(hash_map, "key2") == "value 2"
  end

  test "map/2" do
    hash_map =
      HashMap.new()
      |> HashMap.put("key1", "value1")
      |> HashMap.put("key2", "value2")
      |> HashMap.put("key3", "value3")
      |> HashMap.map(fn {_key, value} -> value <> "!" end)

    assert HashMap.get(hash_map, "key1") == "value1!"
    assert HashMap.get(hash_map, "key2") == "value2!"
    assert HashMap.get(hash_map, "key3") == "value3!"
  end

  test "filter/2" do
    hash_map =
      HashMap.new()
      |> HashMap.put(1, 1)
      |> HashMap.put(2, 4)
      |> HashMap.put(3, 9)
      |> HashMap.filter(fn {_k, v} -> rem(v, 2) == 1 end)

    assert HashMap.get(hash_map, 1) == 1
    refute HashMap.get(hash_map, 2)
    assert HashMap.get(hash_map, 3) == 9
  end

  test "merge/2" do
    left_hash_map =
      HashMap.new()
      |> HashMap.put("first_key", 1)
      |> HashMap.put("second_key", 2)

    right_hash_map =
      HashMap.new()
      |> HashMap.put("third_key", 3)
      |> HashMap.put("first_key", -1)

    merged_hash_map = HashMap.merge(left_hash_map, right_hash_map)

    assert HashMap.get(merged_hash_map, "first_key") == -1
    assert HashMap.get(merged_hash_map, "second_key") == 2
    assert HashMap.get(merged_hash_map, "third_key") == 3
  end

  test "merge/2 different size" do
    left_hash_map =
      HashMap.new(32)
      |> HashMap.put("first_key", 1)
      |> HashMap.put("second_key", 2)

    right_hash_map =
      HashMap.new(2)
      |> HashMap.put("third_key", 3)
      |> HashMap.put("first_key", -1)

    merged_hash_map = HashMap.merge(left_hash_map, right_hash_map)

    assert merged_hash_map.buckets_count == left_hash_map.buckets_count
    assert HashMap.get(merged_hash_map, "first_key") == -1
    assert HashMap.get(merged_hash_map, "second_key") == 2
    assert HashMap.get(merged_hash_map, "third_key") == 3
  end

  test "collission resolves" do
    hash_map =
      1
      |> HashMap.new()
      |> HashMap.put("first_key", 1)
      |> HashMap.put("second_key", 2)

    assert HashMap.get(hash_map, "first_key") == 1
    assert HashMap.get(hash_map, "second_key") == 2
  end

  test "reduce/2 on empty hash map with nil acc" do
    actual_value =
      4
      |> HashMap.new()
      |> HashMap.reduce(fn {_key, value}, acc -> acc + value end)

    refute actual_value
  end

  test "reduce/2 on empty hash map" do
    expected_value = 0

    actual_value =
      4
      |> HashMap.new()
      |> HashMap.reduce(0, fn {_key, value}, acc -> acc + value end)

    assert actual_value == expected_value
  end

  test "reduce/2" do
    expected_result = 15

    actual_result =
      4
      |> HashMap.new()
      |> HashMap.put(1, 1)
      |> HashMap.put(2, 2)
      |> HashMap.put(3, 3)
      |> HashMap.put(4, 4)
      |> HashMap.put(5, 5)
      |> HashMap.reduce(0, fn {_key, value}, acc -> acc + value end)

    assert actual_result == expected_result
  end

  test "equal?/2 negative" do
    first_hash_map =
      4
      |> HashMap.new()
      |> HashMap.put(1, 1)

    second_hash_map =
      1
      |> HashMap.new()
      |> HashMap.put(1, 1)

    refute HashMap.equal?(first_hash_map, second_hash_map)

    first_hash_map =
      4
      |> HashMap.new()
      |> HashMap.put(1, 1)

    second_hash_map =
      4
      |> HashMap.new()
      |> HashMap.put(1, 2)

    refute HashMap.equal?(first_hash_map, second_hash_map)

    first_hash_map =
      4
      |> HashMap.new()
      |> HashMap.put(1, 1)

    second_hash_map =
      4
      |> HashMap.new()
      |> HashMap.put(2, 1)

    refute HashMap.equal?(first_hash_map, second_hash_map)
  end

  test "equal/2 positive" do
    first_hash_map =
      4
      |> HashMap.new()
      |> HashMap.put(0, 1)
      |> HashMap.put(2, 3)
      |> HashMap.put(3, 4)

    second_hash_map =
      4
      |> HashMap.new()
      |> HashMap.put(3, 4)
      |> HashMap.put(0, 1)
      |> HashMap.put(2, 3)

    assert HashMap.equal?(first_hash_map, second_hash_map)

    first_hash_map =
      4
      |> HashMap.new()
      |> HashMap.put(0, 1)
      |> HashMap.put(2, 3)
      |> HashMap.remove(3)

    second_hash_map =
      4
      |> HashMap.new()
      |> HashMap.put(0, 1)
      |> HashMap.put(2, 3)

    assert HashMap.equal?(first_hash_map, second_hash_map)
  end
end
