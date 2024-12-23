defmodule Day23 do
  def solution(path) do
    input =
      File.read(path)
      |> elem(1)
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "-", trim: true))
      |> Enum.reduce(%{}, fn [a, b], acc ->
        acc |> Map.update(a, [b], &(&1 ++ [b])) |> Map.update(b, [a], &(&1 ++ [a]))
      end)

    keys = Map.keys(input)

    find_three_connected(keys, input)
    |> Enum.uniq()
    |> Enum.filter(fn x -> Enum.any?(x, &String.starts_with?(&1, "t")) end)
    |> Enum.count()
    |> IO.inspect()

    Map.keys(input)
    |> Enum.reduce([], fn key, acc ->
      connected = find_connected(input, [key], Map.get(input, key))

      if length(connected) > length(acc) do
        connected
      else
        acc
      end
    end)
    |> Enum.sort()
    |> Enum.join(",")
    |> IO.inspect()
  end

  defp find_three_connected([], _), do: []

  defp find_three_connected([head | tail], map) do
    combinations =
      for b <- tail,
          c <- tail,
          b != c,
          three_connected?(map, head, b, c),
          do: [head, b, c] |> Enum.sort()

    combinations ++ find_three_connected(tail, map)
  end

  def three_connected?(map, a, b, c) do
    Map.get(map, a) |> Enum.member?(b) and Map.get(map, a) |> Enum.member?(c) and
      Map.get(map, b) |> Enum.member?(c)
  end

  defp find_connected(_, connected, []), do: connected

  defp find_connected(map, connected, [neighbor | rest]) do
    if Enum.all?(connected, fn node -> Enum.member?(Map.get(map, node), neighbor) end) do
      find_connected(map, [neighbor | connected], rest)
    else
      find_connected(map, connected, rest)
    end
  end
end

Day23.solution("input_test.txt")
Day23.solution("input.txt")
