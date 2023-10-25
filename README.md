# Лабораторная работа №2

## Цель работы

Цель: освоиться с построением пользовательских типов данных, полиморфизмом, рекурсивными алгоритмами и средствами тестирования (unit testing, property-based testing).

В рамках лабораторной работы вам предлагается реализовать одну из предложенных классических структур данных (список, дерево, бинарное дерево, hashmap, граф...).

## Вариант

**HashMap Separate Chain**

## Реализация

```elixir
defmodule HashMap do
  @default_hashmap_size 31

  defstruct buckets: [], size: @default_hashmap_size

  def new(size \\ @default_hashmap_size) do
    buckets = List.duplicate([], size)
    %HashMap{buckets: buckets, size: size}
  end

  def add(hm, key, value) do
    bucket_index = get_bucket_index(hm, key)

    key_index =
      hm.buckets
      |> Enum.at(bucket_index)
      |> Enum.find_index(fn item -> elem(item, 0) == key end)

    buckets =
      hm.buckets
      |> List.update_at(
        bucket_index,
        fn b ->
          case key_index do
            nil -> [{key, value} | b]
            _ -> List.keystore(b, key, key_index, {key, value})
          end
        end
      )

    %HashMap{buckets: buckets, size: hm.size}
  end

  def get(hm, key) do
    bucket_index = get_bucket_index(hm, key)

    tuple =
      hm.buckets
      |> Enum.at(bucket_index)
      |> List.keyfind(key, 0)

    case tuple do
      nil -> nil
      tpl -> elem(tpl, 1)
    end
  end

  def pop(hm, key) do
    bucket_index = get_bucket_index(hm, key)

    key_index =
      hm.buckets
      |> Enum.at(bucket_index)
      |> Enum.find_index(fn item -> elem(item, 0) == key end)

    buckets =
      hm.buckets
      |> List.update_at(
        bucket_index,
        fn b ->
          case key_index do
            nil -> b
            _ -> List.keydelete(b, key, 0)
          end
        end
      )

    %HashMap{buckets: buckets, size: hm.size}
  end

  def map(hm, function) do
    List.flatten(hm.buckets)
    |> Enum.map(function)
  end

  def foldl(hm, acc, function) do
    List.flatten(hm.buckets)
    |> Enum.reduce(acc, function)
  end

  def foldr(hm, acc, function) do
    List.flatten(hm.buckets)
    |> Enum.reverse()
    |> Enum.reduce(acc, function)
  end

  def filter(hm, function) do
    filtered_buckets =
      hm.buckets
      |> Enum.map(fn bucket -> Enum.filter(bucket, function) end)

    %HashMap{buckets: filtered_buckets, size: hm.size}
  end

  defp get_bucket_index(hm, key) do
    rem(hash(key), hm.size)
  end

  defp hash(key) do
    :erlang.phash2(key)
  end
end
```

## Модульное тестирование

```elixir
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
```