defmodule Day10 do
  def solution(path) do
    input =
      File.read(path)
      |> elem(1)
      |> String.split("\n", trim: true)

    for(
      {row, y} <- Enum.with_index(input),
      {cell, x} <- Enum.with_index(String.split(row, "", trim: true)),
      do: {x, y, cell}
    )
    |> Enum.reduce(%{}, fn {x, y, cell}, acc ->
      Map.update(acc, {x, y}, cell, fn _ -> cell end)
    end)
    |> find_regions()
    |> Enum.reduce({0, 0}, fn {_, region}, {acc1, acc2} ->
      {area, perimeter, sides} =
        {calculate_area(region), calculate_perimeter(region), count_sides(region)}

      acc1 = acc1 + area * perimeter
      acc2 = acc2 + area * sides
      {acc1, acc2}
    end)
    |> IO.inspect()
  end

  @neighbors [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]

  defp count_sides(region) do
    region
    |> Enum.map(&is_a_corner(&1, region))
    # |> IO.inspect()
    |> Enum.sum()
  end

  defp top_left_corner({x, y}, region) do
    cond do
      Enum.member?(region, {x - 1, y - 1}) ->
        cond do
          not Enum.member?(region, {x, y - 1}) and not Enum.member?(region, {x - 1, y}) -> 1
          true -> 0
        end

      Enum.member?(region, {x, y - 1}) and Enum.member?(region, {x - 1, y}) ->
        1

      not Enum.member?(region, {x, y - 1}) and not Enum.member?(region, {x - 1, y}) ->
        1

      true ->
        0
    end
  end

  defp top_right_corner({x, y}, region) do
    cond do
      Enum.member?(region, {x + 1, y - 1}) ->
        cond do
          not Enum.member?(region, {x, y - 1}) and not Enum.member?(region, {x + 1, y}) -> 1
          true -> 0
        end

      Enum.member?(region, {x, y - 1}) and Enum.member?(region, {x + 1, y}) ->
        1

      not Enum.member?(region, {x, y - 1}) and not Enum.member?(region, {x + 1, y}) ->
        1

      true ->
        0
    end
  end

  defp bottom_left_corner({x, y}, region) do
    cond do
      Enum.member?(region, {x - 1, y + 1}) ->
        cond do
          not Enum.member?(region, {x, y + 1}) and not Enum.member?(region, {x - 1, y}) -> 1
          true -> 0
        end

      Enum.member?(region, {x, y + 1}) and Enum.member?(region, {x - 1, y}) ->
        1

      not Enum.member?(region, {x, y + 1}) and not Enum.member?(region, {x - 1, y}) ->
        1

      true ->
        0
    end
  end

  defp bottom_right_corner({x, y}, region) do
    cond do
      Enum.member?(region, {x + 1, y + 1}) ->
        cond do
          not Enum.member?(region, {x, y + 1}) and not Enum.member?(region, {x + 1, y}) -> 1
          true -> 0
        end

      Enum.member?(region, {x, y + 1}) and Enum.member?(region, {x + 1, y}) ->
        1

      not Enum.member?(region, {x, y + 1}) and not Enum.member?(region, {x + 1, y}) ->
        1

      true ->
        0
    end
  end

  defp is_a_corner(cell, region) do
    Enum.reduce(
      [&top_left_corner/2, &top_right_corner/2, &bottom_left_corner/2, &bottom_right_corner/2],
      0,
      fn func, acc ->
        acc + func.(cell, region)
      end
    )
  end

  defp calculate_area(region) do
    length(region)
  end

  defp calculate_perimeter(region) do
    region
    |> Enum.reduce(0, fn {x, y}, acc ->
      acc +
        Enum.count(@neighbors, fn {dx, dy} ->
          not Enum.member?(region, {x + dx, y + dy})
        end)
    end)
  end

  def find_regions(field) do
    field
    |> Enum.reduce({%{}, MapSet.new()}, fn {coord, value}, {regions, visited} ->
      if MapSet.member?(visited, coord) do
        {regions, visited}
      else
        {region, new_visited} = explore_region(field, coord, value, MapSet.new())
        {Map.put(regions, coord, region), MapSet.union(visited, new_visited)}
      end
    end)
    |> elem(0)
  end

  defp explore_region(field, coord, value, visited) do
    if MapSet.member?(visited, coord) or Map.get(field, coord) != value do
      {[], visited}
    else
      new_visited = MapSet.put(visited, coord)

      Enum.reduce(@neighbors, {[coord], new_visited}, fn {dx, dy}, {acc_region, acc_visited} ->
        {new_region, new_visited} =
          explore_region(field, {elem(coord, 0) + dx, elem(coord, 1) + dy}, value, acc_visited)

        {acc_region ++ new_region, new_visited}
      end)
    end
  end
end

Day10.solution("input_test.txt")
Day10.solution("input.txt")
