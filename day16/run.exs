defmodule Day16 do
  def solution(path) do
    input =
      File.read(path)
      |> elem(1)
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)

    my = length(input)
    mx = length(Enum.at(input, 0))

    matrix =
      for {row, y} <- Enum.with_index(input),
          {cell, x} <- Enum.with_index(row),
          into: %{},
          do: {{x, y}, cell}

    start = {1, my - 2}
    finish = {mx - 2, 1}

    initial_queue = :gb_trees.from_orddict([{0, {start, 0, 0, 0, matrix}}])

    explore_paths(initial_queue, finish, [])
    # |> Enum.map(fn {steps, turns} -> steps + turns * 1000 end)
    # |> Enum.min()
    |> IO.inspect()
  end

  # east, south, west, north
  @directions %{0 => {1, 0}, 1 => {0, -1}, 2 => {-1, 0}, 3 => {0, 1}}

  def turn_left(dir) do
    dir = dir - 1
    if dir < 0, do: 3, else: dir
  end

  def turn_right(dir) do
    dir = dir + 1
    if dir > 3, do: 0, else: dir
  end

  def explore_paths(queue, finish, paths) do
    if :gb_trees.is_empty(queue) do
      paths
    else
      {_, {pos, dir, steps, turns, matrix}, rest} = :gb_trees.take_smallest(queue)

      {updated_queue, updated_paths} =
        if pos == finish do
          {rest, [{steps, turns} | paths]}
        else
          next_steps =
            [
              move(pos, dir, steps, turns, matrix),
              move(pos, turn_left(dir), steps, turns + 1, matrix),
              move(pos, turn_right(dir), steps, turns + 1, matrix)
            ]
            |> Enum.filter(fn {pos, _, _, _, matrix} ->
              Map.get(matrix, pos) != "#" and Map.get(matrix, pos) != "O"
            end)
            |> Enum.reduce(rest, fn next, acc ->
              {_, _, steps, turns, _} = next
              :gb_trees.enter(steps + turns * 1000, next, acc)
            end)

          {next_steps, paths}
        end

      explore_paths(updated_queue, finish, updated_paths)
    end
  end

  def move(pos, dir, steps, turns, matrix) do
    {dx, dy} = @directions[dir]
    {x, y} = pos
    next_pos = {x + dx, y + dy}
    {next_pos, dir, steps + 1, turns, Map.update(matrix, pos, "", fn _ -> "O" end)}
  end
end

Day16.solution("input_test.txt")
Day16.solution("input_test2.txt")
# Day16.solution("input.txt")
