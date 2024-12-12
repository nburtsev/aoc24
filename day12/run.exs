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

  defp count_sides(region) do
    region
    |> Enum.map(&is_a_corner(&1, region))
    |> Enum.sum()
  end

  defp check_corner(neighbors, {x, y}, region) do
    [diagonal, side1, side2] =
      Enum.map(neighbors, &Enum.member?(region, {x + elem(&1, 0), y + elem(&1, 1)}))

    cond do
      diagonal and not side1 and not side2 -> 1
      not diagonal and side1 and side2 -> 1
      not diagonal and not side1 and not side2 -> 1
      true -> 0
    end
  end

  defp is_a_corner(cell, region) do
    [
      [{-1, -1}, {0, -1}, {-1, 0}],
      [{1, -1}, {0, -1}, {1, 0}],
      [{-1, 1}, {-1, 0}, {0, 1}],
      [{1, 1}, {0, 1}, {1, 0}]
    ]
    |> Enum.map(&check_corner(&1, cell, region))
    |> Enum.sum()
  end

  defp calculate_area(region) do
    length(region)
  end

  @neighbors [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]

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
