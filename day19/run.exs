defmodule Day19 do
  def solution(path) do
    [available | required] =
      File.stream!(path)
      |> Stream.map(&String.trim/1)
      |> Enum.filter(&(String.length(&1) > 0))

    available = String.split(available, ", ", trim: true) |> MapSet.new()

    max_length =
      Enum.reduce(available, 0, fn x, acc -> max(String.length(x), acc) end)

    required
    |> Enum.reduce(0, fn design, acc ->
      result = check_design(design, available, max_length)

      acc + result
    end)
    |> IO.inspect()
  end

  def check_design(design, available, max_length) do
    design
    |> String.graphemes()
    |> possible_splits(max_length, available)
    |> then(fn x ->
      if length(x) > 0 do
        1
      else
        0
      end
    end)
  end

  defp possible_splits([], _, _), do: [[]]

  defp possible_splits(list, max_length, available) do
    Enum.reduce_while(1..min(max_length, length(list)), [], fn len, acc ->
      {head, rest} = Enum.split(list, len)

      head = Enum.join(head)

      if MapSet.member?(available, head) do
        rest_splits = possible_splits(rest, max_length, available)

        {:halt, Enum.map(rest_splits, fn split -> [head | split] end) ++ acc}
      else
        {:cont, acc}
      end
    end)
  end
end

Day19.solution("input_test.txt")
Day19.solution("input.txt")
