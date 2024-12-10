defmodule Day10 do
  @directions [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def solution(path) do
    {:ok, contents} = File.read(path)

    matrix =
      contents
      |> String.split("\n", trim: true)
      |> Enum.map(fn x ->
        x |> String.graphemes() |> Enum.map(&String.to_integer/1)
      end)

    trailheads =
      for {row, y} <- Enum.with_index(matrix),
          {cell, x} <- Enum.with_index(row),
          cell == 0,
          do: {x, y, cell}

    trailheads
    |> Enum.map(fn x ->
      find_trail(matrix, x)
      |> List.flatten()
      # part one counts unique ends, part two counts all paths to all ends
      # |> MapSet.new()
      # |> MapSet.size()
      |> length()
    end)
    |> Enum.reduce(0, &Kernel.+/2)
    |> IO.inspect()
  end

  defp get_from_matrix(matrix, {x, y}) do
    if y >= 0 and y < length(matrix) and x >= 0 and x < length(Enum.at(matrix, y)) do
      Enum.at(Enum.at(matrix, y), x)
    else
      nil
    end
  end

  defp find_trail(matrix, {x, y, 8}) do
    @directions
    |> Enum.map(fn {dx, dy} -> {get_from_matrix(matrix, {x + dx, y + dy}), x + dx, y + dy} end)
    |> Enum.filter(fn {next, _, _} -> next == 9 end)
    |> Enum.map(fn {_, x, y} -> {x, y} end)
  end

  defp find_trail(matrix, {x, y, height}) do
    @directions
    |> Enum.map(fn {dx, dy} -> {get_from_matrix(matrix, {x + dx, y + dy}), dx, dy} end)
    |> Enum.filter(fn {next, _, _} -> next == height + 1 end)
    |> Enum.map(fn {next, dx, dy} -> find_trail(matrix, {x + dx, y + dy, next}) end)
  end
end

Day10.solution("input_test.txt")
Day10.solution("input.txt")
