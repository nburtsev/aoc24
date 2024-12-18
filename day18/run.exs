defmodule Day18 do
  def solution(path, limit, mx, my) do
    input =
      File.stream!(path)
      |> Stream.map(&String.trim/1)
      |> Enum.map(&String.split(&1, ",", trim: true))
      |> Enum.map(fn [x, y] -> {String.to_integer(x), String.to_integer(y)} end)

    start = {0, 0}
    goal = {mx, my}

    queue = :queue.new()
    queue = :queue.in({start, []}, queue)
    visited = MapSet.new([start])

    {part1_input, _} = Enum.split(input, limit)
    find_path(queue, visited, part1_input, goal, mx, my) |> IO.inspect()

    Enum.reduce_while(input, [], fn {x, y}, acc ->
      acc = [{x, y} | acc]
      path = find_path(queue, visited, acc, goal, mx, my)

      if path == :no_path do
        {:halt, {x, y}}
      else
        {:cont, acc}
      end
    end)
    |> IO.inspect()
  end

  @directions [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]

  def out_of_bounds?(x, y, mx, my) do
    x < 0 or y < 0 or x > mx or y > my
  end

  defp find_path(queue, visited, obstacles, goal, mx, my) do
    case :queue.out(queue) do
      {:empty, _queue} ->
        :no_path

      {{:value, {{x, y}, path}}, queue} ->
        if {x, y} == goal do
          length(path)
        else
          neighbors =
            for {dx, dy} <- @directions,
                do: {x + dx, y + dy}

          unvisited_neighbors =
            Enum.filter(neighbors, fn {nx, ny} ->
              not MapSet.member?(visited, {nx, ny}) and not Enum.member?(obstacles, {nx, ny}) and
                not out_of_bounds?(nx, ny, mx, my)
            end)

          new_visited = Enum.reduce(unvisited_neighbors, visited, &MapSet.put(&2, &1))

          new_queue =
            Enum.reduce(unvisited_neighbors, queue, fn neighbor, acc ->
              :queue.in({neighbor, [neighbor | path]}, acc)
            end)

          find_path(new_queue, new_visited, obstacles, goal, mx, my)
        end
    end
  end
end

Day18.solution("input_test.txt", 12, 6, 6)
Day18.solution("input.txt", 1024, 70, 70)
