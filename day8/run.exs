defmodule Day8 do
  def solution(path) do
    {:ok, contents} = File.read(path)

    matrix =
      contents
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)

    nodes =
      for {row, y} <- Enum.with_index(matrix),
          {cell, x} <- Enum.with_index(row),
          cell != ".",
          do: {cell, x, y}

    {m, n} = {length(matrix), length(Enum.at(matrix, 0))}

    nodes
    |> Enum.group_by(&elem(&1, 0))
    |> Enum.map(fn {_, values} ->
      Enum.map(values, fn {_, x1, y1} ->
        Enum.map(values, fn {_, x2, y2} ->
          if x1 != x2 and y1 != y2 do
            {dx, dy} = {x1 - x2, y1 - y2}
            # part 1 is simple pair
            # [{x1 + dx, y1 + dy}, {x2 - dx, y2 - dy}]
            # part 2 is all points inside matrix
            # so just generate them all and then some and filter later on
            Enum.reduce(0..max(m, n), [], fn i, acc ->
              [
                {x1 + i * dx, y1 + i * dy},
                {x2 - i * dx, y2 - i * dy}
                | acc
              ]
            end)
          end
        end)
      end)
      |> List.flatten()
    end)
    |> List.flatten()
    |> Enum.filter(fn x -> x != nil end)
    |> Enum.filter(fn {x, y} -> x >= 0 and x < n and y >= 0 and y < m end)
    |> Enum.uniq()
    |> length()
    |> IO.inspect()
  end
end

Day8.solution("input_test.txt")
Day8.solution("input.txt")
