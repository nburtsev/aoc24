defmodule Day16 do
  @directions %{0 => {1, 0}, 1 => {0, -1}, 2 => {-1, 0}, 3 => {0, 1}}

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

    heap = Heap.min() |> Heap.push({0, start, 0, []})

    min_cost = :infinity
    {min_cost, paths} = dijkstra(matrix, heap, finish, MapSet.new(), [], min_cost)

    IO.puts("Part 1: #{min_cost}")
    IO.puts("Parth 2: #{(paths |> Enum.flat_map(&elem(&1, 1)) |> Enum.uniq() |> length()) + 1}")
  end

  def dijkstra(map, heap, finish, visited, paths, min_cost) do
    case Heap.empty?(heap) do
      true ->
        {min_cost, paths}

      false ->
        {{cost, {x, y}, dir, path}, rest} = Heap.split(heap)

        if cost > min_cost do
          dijkstra(map, rest, finish, visited, paths, min_cost)
        else
          next_visited = MapSet.put(visited, {x, y, dir})

          {next_heap, min_cost, next_paths} =
            if {x, y} == finish do
              min_cost = cost
              {rest, min_cost, [{cost, path} | paths]}
            else
              next_heap =
                [dir, turn_left(dir), turn_right(dir)]
                |> Enum.map(fn new_dir ->
                  {dx, dy} = @directions[new_dir]
                  cost = if dir == new_dir, do: cost + 1, else: cost + 1001
                  {cost, {x + dx, y + dy}, new_dir, [{x, y} | path]}
                end)
                |> Enum.reject(fn {_, {x, y}, new_dir, _} ->
                  Map.get(map, {x, y}) == "#" or {x, y, new_dir} in next_visited or
                    cost > min_cost
                end)
                |> Enum.reduce(rest, fn state, heap -> Heap.push(heap, state) end)

              {next_heap, min_cost, paths}
            end

          dijkstra(map, next_heap, finish, next_visited, next_paths, min_cost)
        end
    end
  end

  def turn_left(dir) do
    dir = dir - 1

    if dir < 0 do
      3
    else
      dir
    end
  end

  def turn_right(dir) do
    dir = dir + 1

    if dir > 3 do
      0
    else
      dir
    end
  end
end

Mix.install([{:heap, "~> 3.0.0"}])
Day16.solution("input_test.txt")
Day16.solution("input_test2.txt")
Day16.solution("input.txt")
