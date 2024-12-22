defmodule Day20 do
  @directions %{0 => {1, 0}, 1 => {0, -1}, 2 => {-1, 0}, 3 => {0, 1}}

  def solution(path) do
    input =
      File.read(path)
      |> elem(1)
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)

    # my = length(input)
    # mx = length(Enum.at(input, 0))

    matrix =
      for {row, y} <- Enum.with_index(input),
          {cell, x} <- Enum.with_index(row),
          into: %{},
          do: {{x, y}, cell}

    start = Enum.find(matrix, fn {_, cell} -> cell == "S" end) |> elem(0)
    finish = Enum.find(matrix, fn {_, cell} -> cell == "E" end) |> elem(0)

    IO.inspect(start)
    IO.inspect(finish)
    matrix = Map.put(matrix, start, ".") |> Map.put(finish, ".")
    heap = Heap.min() |> Heap.push({0, start, []})

    min_cost = :infinity

    {r, [path]} = dijkstra(matrix, heap, finish, MapSet.new(), [], min_cost) |> IO.inspect()

    race_length =
      Enum.reduce(matrix, 0, fn {_, cell}, acc ->
        if cell == "." do
          acc + 1
        else
          acc
        end
      end) - 1

    IO.puts("Race length: #{race_length}")
    IO.inspect(path)

    walls_that_can_be_cheated =
      Enum.filter(matrix, fn {{x, y}, cell} ->
        cell == "#" and
          ((Map.get(matrix, {x - 1, y}) == "." and Map.get(matrix, {x + 1, y}) == ".") or
             (Map.get(matrix, {x, y - 1}) == "." and Map.get(matrix, {x, y + 1}) == "."))
      end)

    IO.inspect(length(walls_that_can_be_cheated), label: "Walls that can be cheated")

    Enum.map(walls_that_can_be_cheated, fn {{x, y}, _} ->
      map = Map.put(matrix, {x, y}, ".")
      dijkstra(map, heap, finish, MapSet.new(), [], race_length)
    end)
    # |> IO.inspect()
    |> Enum.map(fn {cost, _} ->
      race_length - cost
    end)
    |> Enum.group_by(& &1)
    |> Enum.map(fn {key, value} -> {key, length(value)} end)
    |> IO.inspect()
    |> Enum.filter(fn {savings, _} -> savings >= 100 end)
    |> Enum.reduce(0, fn {_, count}, acc -> acc + count end)
    |> IO.inspect()
  end

  def dijkstra(map, heap, finish, visited, paths, min_cost) do
    case Heap.empty?(heap) do
      true ->
        {min_cost, paths}

      false ->
        {{cost, {x, y}, path}, rest} = Heap.split(heap)

        if cost > min_cost do
          dijkstra(map, rest, finish, visited, paths, min_cost)
        else
          next_visited = MapSet.put(visited, {x, y})

          {next_heap, min_cost, next_paths} =
            if {x, y} == finish do
              min_cost = cost
              {rest, min_cost, [path | paths]}
            else
              next_heap =
                @directions
                |> Enum.map(fn {_, new_dir} ->
                  {dx, dy} = new_dir
                  cost = cost + 1
                  {cost, {x + dx, y + dy}, [{x, y} | path]}
                end)
                |> Enum.reject(fn {_, {x, y}, _} ->
                  Map.get(map, {x, y}) == "#" or {x, y} in next_visited or
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
Day20.solution("input_test.txt")
Day20.solution("input.txt")
