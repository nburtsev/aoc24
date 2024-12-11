defmodule Day10 do
  def solution(path) do
    {:ok, contents} = File.read(path)

    stones =
      contents
      |> String.trim()
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    count =
      Enum.reduce(stones, %{}, fn x, acc ->
        Map.update(acc, x, 1, fn count -> count + 1 end)
      end)

    Enum.reduce(1..75, count, fn x, acc ->
      Map.keys(acc)
      |> Enum.reduce(%{}, fn y, acc2 ->
        old_count = Map.get(acc, y, 0)

        y
        |> change()
        |> Enum.reduce(acc2, fn z, acc3 ->
          Map.update(acc3, z, old_count, fn count -> count + old_count end)
        end)
      end)
    end)
    |> Map.values()
    |> Enum.sum()
    |> IO.inspect()
  end

  defp change(stone) do
    cond do
      stone == 0 ->
        [1]

      rem(String.length(Integer.to_string(stone)), 2) == 0 ->
        l = div(String.length(Integer.to_string(stone)), 2)

        [div(stone, 10 ** l), rem(stone, 10 ** l)]

      true ->
        [stone * 2024]
    end
  end
end

Day10.solution("input_test.txt")
Day10.solution("input.txt")
