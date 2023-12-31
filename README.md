# Лабораторная работа №2

## Цель работы

Цель: освоиться с построением пользовательских типов данных, полиморфизмом, рекурсивными алгоритмами и средствами тестирования (unit testing, property-based testing).

В рамках лабораторной работы вам предлагается реализовать одну из предложенных классических структур данных (список, дерево, бинарное дерево, hashmap, граф...).

## Вариант

**HashMap Separate Chain**

![Изображение](docs/hash_map_separate_chaning.png)

## Реализация

- [Исходный код](lib/hashmap.ex)
- [Модульные тесты](test/hashmap_unit_test.exs)
- [Property-based тесты](test/hashmap_property_test.exs)

### Особенности реализации

- Добавлены аннотации типов, подключен dialyzer.
- Не используется сахар из модулей Enum и List.
- При инициализации количество бакетов равно нулю. Они создаются только при получении нового хэша.
- Переопределена операция сравнения, чтобы не поддерживать сортировку элементов внутри бакетов.
- Правая свертка не была реализована. Не увидел в этой операции никакого смысла. На прикладном уровне это Unordered Dict.
- Доказательство того, что структура является монодом, делается с помощью нескольких тестов:
  - Ассоциативность: `merge(merge(hm1, hm2), hm3) = merge(hm1, merge(hm2, hm3))`.
  - Нейтральность. Сложение хэшмапы с пустой хэшмапой дает исходную хэшмапу.

## Выводы

Мне было больно делать эту лабораторную работу, так как асимптотическая сложность данной HashMap'ы оставляет желать лучшего. Из-за того, что все построено на связных списках, все операции выполняются за O(N). 

Отсутствие индексации убивает весь смысл хэш-таблиц.

Тем не менее, в процессе работы ознакомился с некоторым количеством проектов, откуда я почерпнул несколько интересных фишек Elixir, например, использование `struct`, `__MODULE__` и функций без тела. 

А также поработал со списками без использования Enum и List, это необычный опыт.
