defmodule Day4 do
  def solution(path) do
    {:ok, contents} = File.read(path)

    matrix =
      contents
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)

    x_positions =
      for {row, y} <- Enum.with_index(matrix),
          {cell, x} <- Enum.with_index(row),
          cell == "X",
          do: {x, y}

    neighbors = [{-1, 0}, {1, 0}, {0, -1}, {0, 1}, {1, 1}, {-1, -1}, {1, -1}, {-1, 1}]

    x_with_mas =
      for {x, y} <- x_positions,
          {dx, dy} <- neighbors,
          get_from_matrix(matrix, {x + dx, y + dy}) == "M",
          get_from_matrix(matrix, {x + 2 * dx, y + 2 * dy}) == "A",
          get_from_matrix(matrix, {x + 3 * dx, y + 3 * dy}) == "S",
          do: {x, y}

    IO.inspect(length(x_with_mas))

    a_positions =
      for {row, y} <- Enum.with_index(matrix),
          {cell, x} <- Enum.with_index(row),
          cell == "A",
          do: {x, y}

    # M . M  S . S  S . M
    # . A .  . A .  . A .
    # S . S  M . M  M . S

    a_with_sam_mas =
      a_positions
      |> Enum.map(fn {x, y} ->
        d1 =
          get_from_matrix(matrix, {x + 1, y + 1}) == "M" and
            get_from_matrix(matrix, {x - 1, y - 1}) == "S"

        d2 =
          get_from_matrix(matrix, {x + 1, y + 1}) == "S" and
            get_from_matrix(matrix, {x - 1, y - 1}) == "M"

        d3 =
          get_from_matrix(matrix, {x + 1, y - 1}) == "M" and
            get_from_matrix(matrix, {x - 1, y + 1}) == "S"

        d4 =
          get_from_matrix(matrix, {x + 1, y - 1}) == "S" and
            get_from_matrix(matrix, {x - 1, y + 1}) == "M"

        (d1 or d2) and (d3 or d4)
      end)
      |> Enum.count(fn x -> x end)

    IO.inspect(a_with_sam_mas)
  end

  defp get_from_matrix(matrix, {x, y}) do
    if y >= 0 and y < length(matrix) and x >= 0 and x < length(Enum.at(matrix, y)) do
      Enum.at(Enum.at(matrix, y), x)
    else
      nil
    end
  end
end

Day4.solution("input_test.txt")
Day4.solution("input.txt")
