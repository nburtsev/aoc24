defmodule Day6 do
  def solution(path) do
    {:ok, contents} = File.read(path)

    matrix =
      contents
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)

    [start | _] =
      for {row, y} <- Enum.with_index(matrix),
          {cell, x} <- Enum.with_index(row),
          cell == "^",
          do: {x, y}

    {steps, _, loop_counter} = move(matrix, start, 0, 0, 0, false, 0)
    IO.inspect(steps)
    IO.inspect(loop_counter)
  end

  defp move(matrix, {x, y}, direction, steps, loop_counter, checking_for_loop, loop_steps) do
    directions = %{
      0 => {0, -1},
      1 => {1, 0},
      2 => {0, 1},
      3 => {-1, 0}
    }

    {dx, dy} = directions[direction]
    {nx, ny} = {x + dx, y + dy}
    matrix = List.replace_at(matrix, y, List.replace_at(Enum.at(matrix, y), x, "X"))

    cond do
      ny < 0 or ny >= length(matrix) or nx < 0 or nx >= length(Enum.at(matrix, 0)) ->
        {steps + 1, matrix, loop_counter}

      loop_steps > length(matrix) * length(Enum.at(matrix, 0)) ->
        # IO.puts("loop matrix")
        # IO.inspect(matrix)
        {steps, matrix, loop_counter + 1}

      Enum.at(Enum.at(matrix, ny), nx) == "#" or Enum.at(Enum.at(matrix, ny), nx) == "O" ->
        new_direction = rem(direction + 1, 4)

        move(
          matrix,
          {x, y},
          new_direction,
          steps,
          loop_counter,
          checking_for_loop,
          loop_steps
        )

      Enum.at(Enum.at(matrix, ny), nx) == "X" ->
        move(matrix, {nx, ny}, direction, steps, loop_counter, checking_for_loop, loop_steps + 1)

      checking_for_loop == true ->
        move(
          matrix,
          {nx, ny},
          direction,
          steps + 1,
          loop_counter,
          checking_for_loop,
          loop_steps + 1
        )

      true ->
        new_matrix = List.replace_at(matrix, ny, List.replace_at(Enum.at(matrix, ny), nx, "O"))
        {_, _, loop_counter} = move(new_matrix, {x, y}, direction, steps, loop_counter, true, 0)
        move(matrix, {nx, ny}, direction, steps + 1, loop_counter, checking_for_loop, loop_steps)
    end
  end
end

Day6.solution("input_test.txt")
Day6.solution("input.txt")
