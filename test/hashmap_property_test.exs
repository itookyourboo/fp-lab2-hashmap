defmodule HashMapPropertyTest do
  use ExUnit.Case
  use ExUnitProperties

  property "Neutral property" do
    check all %HashMap{buckets_count: count} = hash_map <- valid_hash_map_generator() do
      empty_hash_map = HashMap.new(count)

      merged_hash_map = HashMap.merge(hash_map, empty_hash_map)

      assert HashMap.equal?(merged_hash_map, hash_map)
      assert HashMap.equal?(hash_map, merged_hash_map)

      merged_hash_map = HashMap.merge(empty_hash_map, hash_map)

      assert HashMap.equal?(merged_hash_map, hash_map)
      assert HashMap.equal?(hash_map, merged_hash_map)
    end
  end

  property "Associative property" do
    check all hm1 <- valid_hash_map_generator(),
              hm2 <- valid_hash_map_generator(),
              hm3 <- valid_hash_map_generator() do

      assert HashMap.equal?(
        HashMap.merge(HashMap.merge(hm1, hm2), hm3),
        HashMap.merge(hm1, HashMap.merge(hm2, hm3))
      )

    end
  end

  defp valid_hash_map_generator do
    gen all buckets_count <- integer(1..32),
            list <- list_of({integer(), integer()}) do
      put_elements(buckets_count, list)
    end
  end

  defp put_elements(buckets_count, elements) do
    Enum.reduce(elements, HashMap.new(buckets_count), fn {key, value}, acc ->
      HashMap.put(acc, key, value)
    end)
  end
end
