# credo:disable-for-this-file Credo.Check.Readability.ModuleDoc
defmodule HashMap do
  # Объявляем типы для более удобной работы
  @type hash :: non_neg_integer()
  @type pair :: {any(), any()}
  @type bucket :: {hash(), [pair()]}
  # Тип t указывает на объект HashMap
  @type t :: %__MODULE__{buckets: [bucket()], buckets_count: non_neg_integer()}

  # Количество бакетов по умолчанию
  @default_buckets_count 32

  # Структура хранит список бакетов и их количество
  # Бакет представляет собой список кортежей (ключ; значение)
  defstruct buckets: [], buckets_count: @default_buckets_count

  # Инициализация структуры
  @spec new(buckets_count :: non_neg_integer()) :: t()
  def new(buckets_count \\ @default_buckets_count) when buckets_count >= 1 do
    # %__MODULE__ - это текущий модуль, в данном случае HashMap
    # Если поменять название HashMap -> HashMapSeparateChaining,
    # то это не затронет другие функции
    %__MODULE__{buckets: [], buckets_count: buckets_count}
  end

  # Добавление значения по ключу
  @spec put(hash_map :: t(), key :: any(), value :: any()) :: t()
  def put(%__MODULE__{buckets: buckets, buckets_count: buckets_count} = hash_map, key, value) do
    hashed_key = hash_key(key, buckets_count)
    # struct позволяет обновить поля структуры
    struct(hash_map, buckets: put_bucket_value(buckets, hashed_key, key, value))
  end

  # Получение значения по ключу
  @spec get(hash_map :: t(), key :: any()) :: any()
  def get(%__MODULE__{buckets: buckets, buckets_count: buckets_count}, key) do
    hashed_key = hash_key(key, buckets_count)
    get_bucket_value(buckets, hashed_key, key)
  end

  # Удаление значения по ключу
  @spec remove(hash_map :: t(), key :: any()) :: t()
  def remove(%__MODULE__{buckets: buckets, buckets_count: buckets_count} = hash_map, key) do
    hashed_key = hash_key(key, buckets_count)
    struct(hash_map, buckets: remove_bucket_key(buckets, hashed_key, key))
  end

  # Операция отображения по каждому элементу,
  # представленному в виде (ключ; значение)
  @spec map(hash_map :: t(), function :: function()) :: t()
  def map(%__MODULE__{buckets: buckets} = hash_map, function) do
    struct(hash_map, buckets: map_buckets(buckets, function))
  end

  # Фильтрация с помощью функции по паре (ключ; значение)
  @spec filter(hash_map :: t(), function :: function()) :: t()
  def filter(%__MODULE__{buckets: buckets} = hash_map, function) do
    struct(hash_map, buckets: filter_buckets(buckets, function))
  end

  # Операция слияния двух структур.
  # Одинаковые поля переписываются второй структурой
  #
  @spec merge(left_hash_map :: t(), right_hash_map :: t()) :: t()
  def merge(
        %__MODULE__{buckets: left_buckets, buckets_count: left_buckets_count} = left_hash_map,
        %__MODULE__{
          buckets: right_buckets,
          buckets_count: right_buckets_count
        }
      )
      when left_buckets_count == right_buckets_count do
    struct(left_hash_map, buckets: merge_buckets(right_buckets, left_buckets))
  end

  def merge(
        %__MODULE__{buckets_count: left_buckets_count} = left_hash_map,
        %__MODULE__{buckets_count: right_buckets_count} = right_hash_map
      )
      when left_buckets_count < right_buckets_count do
    merge(resize(left_hash_map, right_buckets_count), right_hash_map)
  end

  def merge(
        %__MODULE__{buckets_count: left_buckets_count} = left_hash_map,
        %__MODULE__{buckets_count: right_buckets_count} = right_hash_map
      )
      when left_buckets_count > right_buckets_count do
    merge(left_hash_map, resize(right_hash_map, left_buckets_count))
  end

  @spec resize(hash_map :: t(), new_buckets_count :: non_neg_integer()) :: t()
  def resize(hash_map, new_buckets_count) do
    reduce(hash_map, HashMap.new(new_buckets_count), fn {key, value}, new_hash_map ->
      HashMap.put(new_hash_map, key, value)
    end)
  end

  # Операция свертки по паре (ключ; значение))
  def reduce(hash_map, function) do
    reduce(hash_map, nil, function)
  end

  def reduce(%__MODULE__{buckets: buckets}, acc, function) do
    reduce_buckets(buckets, acc, function)
  end

  # Проверка на равенство двух структур
  # Структуры равны, если все бакеты равны.
  def equal?(%__MODULE__{buckets: left_buckets, buckets_count: left_buckets_count}, %__MODULE__{
        buckets: right_buckets,
        buckets_count: right_buckets_count
      })
      when left_buckets_count == right_buckets_count do
    buckets_equal?(left_buckets, right_buckets)
  end

  # Если количество бакетов разное,
  # возвращаем false
  def equal?(_, _), do: false

  # Прокидываем наружу константу модуля
  def default_buckets_count do
    @default_buckets_count
  end

  # Хэширующая функция
  # За основу берется встроенная :erlang.phash2().
  # Затем этот хэш делится по модулю на количество бакетов
  defp hash_key(key, buckets_count) do
    key
    |> :erlang.phash2()
    |> rem(buckets_count)
  end

  # Функция без тела нужна для объявления значения по умолчанию
  defp put_bucket_value(buckets, hash, key, value, acc \\ [])

  # Если не нашли бакет с таким хэшем, вставляем его в нашу хэшмапу
  defp put_bucket_value([], hash, key, value, acc) do
    [{hash, [{key, value}]} | acc]
  end

  # Если нашли бакет с таким хэшем, вставляем в него наш элемент
  defp put_bucket_value([{current_hash, items} | tail], hash, key, value, acc)
       when current_hash == hash do
    [{current_hash, put_value(items, key, value)} | acc] ++ tail
  end

  defp put_bucket_value([head | tail], hash, key, value, acc) do
    put_bucket_value(tail, hash, key, value, [head | acc])
  end

  defp put_value(items, key, value, acc \\ [])

  # Вставляем значение в начало списка, если ключ не был найден
  defp put_value([], key, value, acc) do
    [{key, value} | acc]
  end

  # Если мы нашли ключ, то заменяем элемент новым значением
  defp put_value([{current_key, _} = head | tail], key, value, acc) do
    if current_key == key do
      tail ++ [{key, value} | acc]
    else
      put_value(tail, key, value, [head | acc])
    end
  end

  defp get_bucket_value([], _hash, _key), do: nil

  defp get_bucket_value([{current_hash, items} | _tail], hash, key) when hash == current_hash do
    get_value(items, key)
  end

  defp get_bucket_value([_head | tail], hash, key) do
    get_bucket_value(tail, hash, key)
  end

  defp get_value([], _key), do: nil

  defp get_value([{current_key, value} | _tail], key) when current_key == key, do: value

  defp get_value([_ | tail], key), do: get_value(tail, key)

  defp remove_bucket_key(buckets, hash, key, acc \\ [])

  defp remove_bucket_key([], _hash, _key, acc), do: acc

  defp remove_bucket_key([{current_hash, items} | tail], hash, key, acc)
       when current_hash == hash do
    [{current_hash, remove_key(items, key)} | acc] ++ tail
  end

  defp remove_bucket_key([head | tail], hash, key, acc) do
    remove_bucket_key(tail, hash, key, [head | acc])
  end

  defp remove_key(items, key, acc \\ [])

  defp remove_key([], _key, acc), do: acc

  defp remove_key([{current_key, _} | tail], key, acc) when current_key == key, do: tail ++ acc

  defp remove_key([head | tail], key, acc), do: remove_key(tail, key, [head | acc])

  defp map_buckets(buckets, function, acc \\ [])

  defp map_buckets([], _function, acc), do: acc

  defp map_buckets([{current_hash, items} | tail], function, acc) do
    map_buckets(tail, function, [{current_hash, map_items(items, function)} | acc])
  end

  defp map_items(items, function, acc \\ [])

  defp map_items([], _function, acc), do: acc

  defp map_items([{key, _value} = head | tail], function, acc),
    do: map_items(tail, function, [{key, function.(head)} | acc])

  defp filter_buckets(buckets, function, acc \\ [])

  defp filter_buckets([], _function, acc), do: acc

  defp filter_buckets([{current_hash, items} | tail], function, acc) do
    filter_buckets(tail, function, [
      {current_hash, filter_elements(items, function)} | acc
    ])
  end

  defp filter_elements(items, function, acc \\ [])

  defp filter_elements([], _function, acc), do: acc

  defp filter_elements([head | tail], function, acc) do
    if function.(head) do
      filter_elements(tail, function, [head | acc])
    else
      filter_elements(tail, function, acc)
    end
  end

  defp merge_buckets([], right_buckets), do: right_buckets

  defp merge_buckets([{hash, items} | tail], right_bucket) do
    merge_buckets(tail, merge_bucket_items(right_bucket, hash, items))
  end

  defp merge_bucket_items(bucket, hash, items, acc \\ [])

  defp merge_bucket_items([], hash, items, acc), do: [{hash, items} | acc]

  defp merge_bucket_items([{current_hash, current_items} | tail], hash, items, acc)
       when current_hash == hash do
    [{current_hash, merge_items(items, current_items)} | acc] ++ tail
  end

  defp merge_bucket_items([head | tail], hash, items, acc) do
    merge_bucket_items(tail, hash, items, [head | acc])
  end

  defp merge_items([], right_hash_map), do: right_hash_map

  defp merge_items([{key, value} | tail], right_hash_map) do
    merge_items(tail, put_value(right_hash_map, key, value))
  end

  defp reduce_buckets([], acc, _function) do
    acc
  end

  defp reduce_buckets([{_hash, items} | tail], acc, function) do
    reduce_buckets(tail, reduce_items(items, acc, function), function)
  end

  defp reduce_items([], acc, _function), do: acc

  defp reduce_items([head | tail], acc, function) do
    reduce_items(tail, function.(head, acc), function)
  end

  defp buckets_equal?([], []), do: true

  defp buckets_equal?([], _), do: false

  defp buckets_equal?(_, []), do: false

  defp buckets_equal?(left_buckets, right_buckets) do
    do_buckets_equal?(left_buckets, right_buckets)
  end

  defp do_buckets_equal?([], _), do: true

  defp do_buckets_equal?([{hash, items} | tail], buckets) do
    has_bucket_with_items?(buckets, hash, items) and do_buckets_equal?(tail, buckets)
  end

  defp has_bucket_with_items?(_buckets, _hash, []), do: true

  defp has_bucket_with_items?([], _hash, _items), do: false

  defp has_bucket_with_items?([{current_hash, current_items} | _tail], hash, items)
       when current_hash == hash do
    lists_equal?(current_items, items)
  end

  defp has_bucket_with_items?([_head | tail], hash, items) do
    has_bucket_with_items?(tail, hash, items)
  end

  # Списки равны, если все элементы первого содержатся во втором
  # и все элементы второго содержатся в первом
  defp lists_equal?(first, second) do
    list_includes?(first, second) and list_includes?(second, first)
  end

  defp list_includes?([], _), do: true

  defp list_includes?(_, []), do: false

  defp list_includes?([head | tail], lists) do
    head in lists and list_includes?(tail, lists)
  end
end
