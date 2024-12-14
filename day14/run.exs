defmodule Day14 do
  def solution(path, mx, my) do
    center_x = div(mx, 2)
    center_y = div(my, 2)

    input =
      File.read(path)
      |> elem(1)
      |> String.split("\n", trim: true)
      |> Enum.map(fn x ->
        Regex.scan(~r/(-?\d+)/, x) |> Enum.map(&hd/1) |> Enum.map(&String.to_integer/1)
      end)

    # 1..100 for part one
    1..100_000
    |> Enum.reduce_while(input, fn step, acc ->
      a =
        acc
        |> Enum.map(&move_robot(&1, mx, my))

      cond do
        there_is_a_line?(a) ->
          print_grid(step, mx, my, a)
          {:halt, a}

        true ->
          {:cont, a}
      end
    end)
    |> Enum.filter(fn [x, y, _, _] ->
      x != center_x and y != center_y
    end)
    |> Enum.group_by(fn [x, y, _, _] ->
      cond do
        x < center_x && y < center_y -> :top_left
        x > center_x && y < center_y -> :top_right
        x > center_x && y > center_y -> :bottom_right
        x < center_x && y > center_y -> :bottom_left
        true -> :center
      end
    end)
    |> Map.values()
    |> Enum.map(&Enum.count/1)
    |> Enum.product()
    |> IO.inspect()
  end

  defp move_robot([x, y, dx, dy], mx, my) do
    new_x = rem(x + dx, mx)
    new_y = rem(y + dy, my)
    new_x = if new_x < 0, do: new_x + mx, else: new_x
    new_y = if new_y < 0, do: new_y + my, else: new_y
    [new_x, new_y, dx, dy]
  end

  defp print_grid(step, mx, my, cells) do
    IO.puts("Step: #{step}")
    IO.puts(String.duplicate("-", mx + 2))

    grid =
      for y <- 0..(my - 1),
          x <- 0..(mx - 1),
          into: %{},
          do: {{x, y}, " "}

    grid =
      cells
      |> Enum.reduce(grid, fn [x, y | _], acc ->
        Map.put(acc, {x, y}, "#")
      end)

    for y <- 0..(my - 1) do
      IO.write("#{y}|")

      for x <- 0..(mx - 1) do
        IO.write(Map.get(grid, {x, y}))
      end

      IO.puts("|")
    end

    IO.puts(String.duplicate("-", mx + 2))
  end

  defp there_is_a_line?(cells) do
    cell_coordinates =
      cells
      |> Enum.map(fn [x, y | _] -> {x, y} end)

    cell_coordinates
    |> Enum.any?(fn {x, y} ->
      Enum.all?(1..30, fn i -> Enum.member?(cell_coordinates, {x + i, y}) end)
    end)
  end
end

Day14.solution("input_test.txt", 11, 7)
Day14.solution("input.txt", 101, 103)
