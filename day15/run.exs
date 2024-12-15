defmodule Day15 do
  def solution(path) do
    input =
      File.read(path)
      |> elem(1)
      |> String.split("\n\n", trim: true)

    [matrix_string, moves] = input

    matrix =
      String.split(matrix_string, "\n", trim: true) |> Enum.map(&String.graphemes/1)

    matrix =
      for {row, y} <- Enum.with_index(matrix),
          {cell, x} <- Enum.with_index(row),
          into: %{},
          do: {{x, y}, cell}

    robot = Enum.find(matrix, fn {_, cell} -> cell == "@" end) |> elem(0)

    coordinates = %{
      "^" => {0, -1},
      "v" => {0, 1},
      "<" => {-1, 0},
      ">" => {1, 0}
    }

    moves =
      moves
      |> String.graphemes()
      |> Enum.filter(&(&1 != "\n"))
      |> Enum.map(fn x -> coordinates[x] end)

    {_, final_state} =
      moves
      |> Enum.reduce({robot, matrix}, fn move, {robot, matrix} ->
        {nx, ny, new_matrix} = move_object(robot, move, matrix)
        {{nx, ny}, new_matrix}
      end)

    final_state
    |> Enum.filter(fn {_, cell} -> cell == "O" end)
    |> Enum.map(fn {{x, y}, _} -> 100 * y + x end)
    |> Enum.sum()
    |> IO.inspect()

    wide_matrix =
      String.split(matrix_string, "\n", trim: true)
      |> Enum.map(&String.graphemes/1)
      |> Enum.map(fn row ->
        row
        |> Enum.map(fn cell ->
          cond do
            cell == "#" -> "##"
            cell == "." -> ".."
            cell == "@" -> "@."
            true -> "[]"
          end
        end)
        |> Enum.join()
        |> String.graphemes()
      end)
      |> cell_lists_to_map()

    robot = Enum.find(wide_matrix, fn {_, cell} -> cell == "@" end) |> elem(0)

    {_, wide_final_state} =
      moves
      |> Enum.reduce({robot, wide_matrix}, fn move, {robot, matrix} ->
        {nx, ny, new_matrix} = move_robot(robot, move, matrix)
        {{nx, ny}, new_matrix}
      end)

    wide_final_state
    |> Enum.filter(fn {_, cell} -> cell == "[" end)
    |> Enum.map(fn {{x, y}, _} -> 100 * y + x end)
    |> Enum.sum()
    |> IO.inspect()
  end

  def cell_lists_to_map(matrix_string) do
    for {row, y} <- Enum.with_index(matrix_string),
        {cell, x} <- Enum.with_index(row),
        into: %{},
        do: {{x, y}, cell}
  end

  def move_object({x, y}, {dx, dy}, matrix) do
    nx = x + dx
    ny = y + dy
    val = matrix[{x, y}]
    next_val = matrix[{nx, ny}]

    cond do
      next_val == "#" ->
        {x, y, matrix}

      next_val == "O" ->
        {nnx, nny, new_matrix} = move_object({nx, ny}, {dx, dy}, matrix)

        if {nnx, nny} == {nx, ny} do
          {x, y, new_matrix}
        else
          {nx, ny, new_matrix} = move_object({x, y}, {dx, dy}, new_matrix)
          {nx, ny, new_matrix}
        end

      true ->
        new_matrix =
          matrix
          |> Map.update({x, y}, val, fn _ -> next_val end)
          |> Map.update({nx, ny}, next_val, fn _ -> val end)

        {nx, ny, new_matrix}
    end
  end

  # moving robot is easy
  def move_robot({x, y}, {dx, dy}, matrix) do
    val = matrix[{x, y}]
    nx = x + dx
    ny = y + dy
    next_val = matrix[{nx, ny}]

    cond do
      # wall can't move
      next_val == "#" ->
        {x, y, matrix}

      # we always move create by it's left side
      next_val == "[" ->
        {nnx, nny, new_matrix} = move_crate({nx, ny}, {dx, dy}, matrix)
        # if it did not move
        if {nnx, nny} == {nx, ny} do
          # we don't move either
          {x, y, matrix}
        else
          # move the robot
          move_robot({x, y}, {dx, dy}, new_matrix)
        end

      next_val == "]" ->
        nx = nx - 1
        {nnx, nny, new_matrix} = move_crate({nx, ny}, {dx, dy}, matrix)
        # if it did not move
        if {nnx, nny} == {nx, ny} do
          # we don't move either
          {x, y, matrix}
        else
          # move the robot
          move_robot({x, y}, {dx, dy}, new_matrix)
        end

      # next is dot we just move
      true ->
        new_matrix =
          matrix
          |> Map.update({x, y}, val, fn _ -> next_val end)
          |> Map.update({nx, ny}, next_val, fn _ -> val end)

        {nx, ny, new_matrix}
    end
  end

  # move left
  def move_crate({x, y}, {dx, dy}, matrix) when dy == 0 and dx == -1 do
    cond do
      # wall, can't move
      matrix[{x - 1, y}] == "#" ->
        {x, y, matrix}

      # another crate, push it
      matrix[{x - 1, y}] == "]" ->
        {nnx, nny, new_matrix} = move_crate({x - 2, y}, {dx, dy}, matrix)

        # can't push, don't move
        if {nnx, nny} == {x - 2, y} do
          {x, y, matrix}
        else
          # we pushed successfully, now we move and return new_matrix
          {nx, ny, new_matrix} = move_crate({x, y}, {dx, dy}, new_matrix)
          {nx, ny, new_matrix}
        end

      true ->
        new_matrix =
          matrix
          |> Map.update({x - 1, y}, "", fn _ -> "[" end)
          |> Map.update({x, y}, "", fn _ -> "]" end)
          |> Map.update({x + 1, y}, "", fn _ -> "." end)

        {x - 1, y, new_matrix}
    end
  end

  # move right
  def move_crate({x, y}, {dx, dy}, matrix) when dy == 0 and dx == 1 do
    cond do
      # wall, can't move
      matrix[{x + 2, y}] == "#" ->
        {x, y, matrix}

      # another crate, push it
      matrix[{x + 2, y}] == "[" ->
        {nnx, nny, new_matrix} = move_crate({x + 2, y}, {dx, dy}, matrix)

        # can't push, don't move
        if {nnx, nny} == {x + 2, y} do
          {x, y, matrix}
        else
          # we pushed successfully, now we move and return new_matrix
          {nx, ny, new_matrix} = move_crate({x, y}, {dx, dy}, new_matrix)
          {nx, ny, new_matrix}
        end

      true ->
        new_matrix =
          matrix
          |> Map.update({x + 2, y}, "", fn _ -> "]" end)
          |> Map.update({x + 1, y}, "", fn _ -> "[" end)
          |> Map.update({x, y}, "", fn _ -> "." end)

        {x + 1, y, new_matrix}
    end
  end

  # move up or down
  def move_crate({x, y}, {dx, dy}, matrix) do
    {x2, y2} = {x + 1, y}
    # the next position
    nx = x + dx
    ny = y + dy
    nx2 = x2 + dx
    ny2 = y2 + dy

    next_val = matrix[{nx, ny}]
    next_val2 = matrix[{nx2, ny2}]

    cond do
      # we can't move
      next_val == "#" or next_val2 == "#" ->
        {x, y, matrix}

      # we move vertically
      next_val == "." and next_val2 == "." ->
        new_matrix =
          matrix
          |> Map.update({nx, ny}, "", fn _ -> "[" end)
          |> Map.update({nx2, ny2}, "", fn _ -> "]" end)
          |> Map.update({x, y}, "", fn _ -> "." end)
          |> Map.update({x2, y2}, "", fn _ -> "." end)

        {nx, ny, new_matrix}

      # we push
      # we can be aligned, in which case we try to move next crate first
      next_val == "[" ->
        {nnx, nny, new_matrix} = move_crate({nx, ny}, {dx, dy}, matrix)

        if {nnx, nny} == {nx, ny} do
          {x, y, matrix}
        else
          # # we pushed successfully, now we move and return new_matrix
          {nx, ny, new_matrix} = move_crate({x, y}, {dx, dy}, new_matrix)
          {nx, ny, new_matrix}
        end

      # or touching right side of a crate - we push that
      next_val == "]" and next_val2 == "." ->
        {nnx, nny, new_matrix} = move_crate({nx - 1, ny}, {dx, dy}, matrix)

        if {nnx, nny} == {nx - 1, ny} do
          {x, y, matrix}
        else
          # we pushed successfully, now we move and return new_matrix
          {nx, ny, new_matrix} = move_crate({x, y}, {dx, dy}, new_matrix)
          {nx, ny, new_matrix}
        end

      # or touching left side
      next_val == "." and next_val2 == "[" ->
        {nnx, nny, new_matrix} = move_crate({nx + 1, ny}, {dx, dy}, matrix)

        if {nnx, nny} == {nx + 1, ny} do
          {x, y, matrix}
        else
          # we pushed successfully, now we move and return new_matrix
          {nx, ny, new_matrix} = move_crate({x, y}, {dx, dy}, new_matrix)
          {nx, ny, new_matrix}
        end

      # or we can be touching 2 crates
      true ->
        # try to move left touching first
        {nnx, nny, new_matrix} = move_crate({nx - 1, ny}, {dx, dy}, matrix)
        # if we can't - we stop
        if {nnx, nny} == {nx - 1, ny} do
          {x, y, matrix}
        else
          # try moving right one
          {nnx, nny, new_matrix} = move_crate({nx + 1, ny}, {dx, dy}, new_matrix)
          # if we can't - we stop
          if {nnx, nny} == {nx + 1, ny} do
            {x, y, matrix}
          else
            # we pushed both successfully, now we move and return new_matrix
            {nx, ny, new_matrix} = move_crate({x, y}, {dx, dy}, new_matrix)
            {nx, ny, new_matrix}
          end
        end
    end
  end

  def can_move?({x, y}, {dx, dy}, matrix) do
    matrix[{x + dx, y + dy}] != "#"
  end

  def print_map(matrix) do
    {max_x, _} = Enum.max_by(matrix, fn {{x, _}, _} -> x end) |> elem(0)
    {_, max_y} = Enum.max_by(matrix, fn {{_, y}, _} -> y end) |> elem(0)

    for y <- 0..max_y do
      for x <- 0..max_x do
        IO.write(Map.get(matrix, {x, y}, " "))
      end

      IO.puts("")
    end
  end
end

Day15.solution("input_small.txt")
Day15.solution("input_test.txt")
Day15.solution("input.txt")
