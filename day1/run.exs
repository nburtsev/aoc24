defmodule Day1 do
  def solution(path) do
    {:ok, contents} = File.read(path)

    {list1, list2} =
      contents
      |> String.split("\n", trim: true)
      |> Enum.reduce({[], []}, fn line, {list1, list2} ->
        [num1, num2] = String.split(line, "   ", trim: true) |> Enum.map(&String.to_integer/1)
        {[num1 | list1], [num2 | list2]}
      end)

    sorted_list1 = Enum.sort(list1)
    sorted_list2 = Enum.sort(list2)

    result =
      Enum.zip(sorted_list1, sorted_list2)
      |> Enum.map(fn {a, b} -> abs(a - b) end)
      |> Enum.reduce(0, &(&1 + &2))

    IO.inspect(result)

    map2 = Enum.reduce(sorted_list2, %{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)

    result2 =
      Enum.reduce(sorted_list1, 0, fn x, acc ->
        case Map.get(map2, x) do
          nil -> acc
          y -> acc + x * y
        end
      end)

    IO.inspect(result2)
  end
end

Day1.solution("input_test.txt")
Day1.solution("input.txt")
