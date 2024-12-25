defmodule Day25 do
  def solution(path) do
    {locks, keys} =
      File.read(path)
      |> elem(1)
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))
      |> Enum.reduce({[], []}, fn schematic, {locks, keys} ->
        if hd(schematic) == "#####" do
          {[schematic | locks], keys}
        else
          {locks, [schematic | keys]}
        end
      end)

    lock_heights =
      locks
      |> Enum.map(fn lock ->
        lock
        |> Enum.map(&String.split(&1, "", trim: true))
        |> Enum.zip()
        |> Enum.map(&Tuple.to_list/1)
        |> Enum.map(&Enum.count(&1, fn x -> x == "#" end))
        |> Enum.map(&(&1 - 1))
      end)

    # |> IO.inspect()

    key_heights =
      keys
      |> Enum.map(fn key ->
        key
        |> Enum.map(&String.split(&1, "", trim: true))
        |> Enum.zip()
        |> Enum.map(&Tuple.to_list/1)
        |> Enum.map(&Enum.count(&1, fn x -> x == "#" end))
        |> Enum.map(&(&1 - 1))
      end)

    # |> IO.inspect()

    combinations =
      for lock <- lock_heights,
          key <- key_heights,
          into: [],
          do: [lock, key]

    combinations
    |> Enum.map(fn [lock, key] -> Enum.zip(lock, key) end)
    |> Enum.map(fn list -> Enum.map(list, fn {a, b} -> a + b end) end)
    |> Enum.filter(fn list -> Enum.all?(list, fn x -> x < 6 end) end)
    |> Enum.count()
    |> IO.inspect()
  end
end

Day25.solution("input_test.txt")
Day25.solution("input.txt")
