defmodule Day2 do
  def solution(path) do
    {:ok, contents} = File.read(path)

    result =
      contents
      |> String.split("\n", trim: true)
      |> Enum.reduce({0, 0}, fn line, {acc1, acc2} ->
        numbers =
          line
          |> String.split(" ", trim: true)
          |> Enum.map(&String.to_integer/1)

        cond do
          safe?(numbers) -> {acc1 + 1, acc2 + 1}
          can_remove?(numbers) -> {acc1, acc2 + 1}
          true -> {acc1, acc2}
        end
      end)

    IO.inspect(result)
  end

  def safe?(list) do
    Enum.reduce_while(list, {true, true, nil}, fn x, {is_increasing, is_decreasing, prev} ->
      cond do
        prev == nil -> {:cont, {is_increasing, is_decreasing, x}}
        abs(x - prev) < 1 or abs(x - prev) > 3 -> {:halt, {false, false, 0}}
        x > prev -> {:cont, {is_increasing and true, false, x}}
        x < prev -> {:cont, {false, is_decreasing and true, x}}
        true -> {:halt, {false, false, 0}}
      end
    end)
    |> (fn {is_increasing, is_decreasing, _} -> is_increasing or is_decreasing end).()
  end

  def can_remove?(list) do
    Enum.any?(0..(length(list) - 1), fn i ->
      list
      |> List.delete_at(i)
      |> safe?()
    end)
  end
end

Day2.solution("input_test.txt")
Day2.solution("input.txt")
