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
      |> List.update_at(bucket_index,
        fn b ->
          case key_index do
            nil ->  [ {key, value} | b ]
            _   ->  List.keystore(b, key, key_index, {key, value})
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
      |> List.update_at(bucket_index,
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
      |> Enum.reverse
      |> Enum.reduce(acc, function)
  end

  defp get_bucket_index(hm, key) do
    rem(hash(key), hm.size)
  end

  defp hash(key) do
    :erlang.phash2(key)
  end
end