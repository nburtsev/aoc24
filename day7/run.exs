defmodule Day7 do
  def solution(path) do
    {:ok, contents} = File.read(path)

    res =
      contents
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ":", trim: true))
      |> Enum.map(fn [a, b] ->
        {String.to_integer(a), String.split(b, " ", trim: true) |> Enum.map(&String.to_integer/1)}
      end)
      |> Enum.map(fn {result, parts} ->
        # remove concatenate from the list to get part 1, imma lazy
        operators =
          generate_combinations([&+/2, &*/2, &concatenate_integers/2], length(parts) - 1)

        operators
        |> Enum.map(&[hd(parts) | Enum.zip(&1, tl(parts))])
        |> Enum.map(&eval/1)
        |> Enum.find(0, fn x -> x == result end)
      end)
      |> Enum.reduce(0, &+/2)

    IO.inspect(res, charlists: :as_lists)
  end

  defp concatenate_integers(a, b) do
    String.to_integer("#{a}#{b}")
  end

  defp eval([first | operations]) do
    operations
    |> Enum.reduce(
      first,
      fn
        {operator, num}, acc -> operator.(acc, num)
      end
    )
  end

  defp generate_combinations(_, 0), do: [[]]

  defp generate_combinations(elements, max_len) do
    elements
    |> Enum.flat_map(fn element ->
      generate_combinations(elements, max_len - 1)
      |> Enum.map(fn combination -> [element | combination] end)
    end)
  end
end

Day7.solution("input_test.txt")
Day7.solution("input.txt")
