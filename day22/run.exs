defmodule Day22 do
  def solution(path) do
    input =
      File.read(path)
      |> elem(1)
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)

    input
    |> Enum.map(&calculate_nth_secret_number(&1, 2000))
    # |> IO.inspect()
    |> Enum.sum()
    |> IO.inspect()

    input |> Enum.map(&number_to_map_of_diffs(&1, 2000)) |> find_max_sum_key() |> IO.inspect()
  end

  def mix(secret_number, b), do: Bitwise.bxor(b, secret_number)
  def prune(secret_number), do: rem(secret_number, 16_777_216)

  def next_secret_number(secret_number) do
    secret_number = prune(mix(secret_number, secret_number * 64))

    secret_number =
      prune(mix(secret_number, div(secret_number, 32)))

    prune(mix(secret_number, secret_number * 2048))
  end

  def calculate_nth_secret_number(secret_number, n) do
    1..n |> Enum.reduce(secret_number, fn _, acc -> next_secret_number(acc) end)
  end

  def calculate_n_secret_numbers(secret_number, n) do
    1..n
    |> Enum.reduce([secret_number], fn _, [prev | rest] ->
      [next_secret_number(prev), prev | rest]
    end)
    |> Enum.reverse()
  end

  def get_price(secret_number), do: rem(secret_number, 10)

  def number_to_map_of_diffs(starting_number, n) do
    calculate_n_secret_numbers(starting_number, n)
    |> Enum.map(fn secret_number -> {secret_number, get_price(secret_number)} end)
    |> Enum.reduce([{starting_number, get_price(starting_number), 0}], fn {cur_number, cur_price},
                                                                          [
                                                                            {prev_number,
                                                                             prev_price,
                                                                             prev_diff}
                                                                            | rest
                                                                          ] ->
      [
        {cur_number, cur_price, cur_price - prev_price},
        {prev_number, prev_price, prev_diff} | rest
      ]
    end)
    |> Enum.reverse()
    # first element is duplicated, cba to find a better way to do this
    |> tl()
    |> tl()
    |> Enum.reverse()
    |> Enum.chunk_every(4, 1, :discard)
    |> Enum.reduce(%{}, fn group, acc ->
      {_, price, _} = hd(group)
      key = Enum.map(group, fn {_, _, diff} -> diff end)
      Map.put(acc, key, price)
    end)
  end

  def find_max_sum_key(maps) do
    maps
    |> Enum.flat_map(&Map.keys/1)
    |> Enum.uniq()
    |> Enum.map(fn key -> {key, Enum.sum(Enum.map(maps, &Map.get(&1, key, 0)))} end)
    |> Enum.max_by(fn {_, sum} -> sum end)
  end
end

Day22.solution("input_test.txt")
Day22.solution("input.txt")
