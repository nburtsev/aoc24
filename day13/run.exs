defmodule Day13 do
  def solution(path) do
    input =
      File.read(path)
      |> elem(1)
      |> String.split("\n\n", trim: true)
      |> Enum.map(fn x ->
        Regex.scan(~r/(\d+)/, x) |> Enum.map(&hd/1) |> Enum.map(&String.to_integer/1)
      end)

    input
    |> Enum.filter(fn [dx1, dy1, dx2, dy2, x, y] ->
      (dx1 + dx2) * 100 >= x and (dy1 + dy2) * 100 >= y
    end)
    |> Enum.map(&find_minimal_cost/1)
    |> Enum.filter(&(&1 != :infinity))
    |> Enum.sum()
    |> IO.inspect()

    input
    |> Enum.map(fn [dx1, dy1, dx2, dy2, x, y] ->
      [dx1, dy1, dx2, dy2, x + 10_000_000_000_000, y + 10_000_000_000_000]
    end)
    |> Enum.map(&find_minimal_cost/1)
    |> Enum.filter(&(&1 != :infinity))
    |> Enum.sum()
    |> IO.inspect()
  end

  # I wish I knew math
  def find_minimal_cost([dx1, dy1, dx2, dy2, _, _]) when dy2 * dx1 == dx2 * dy1 do
    :infinity
  end

  def find_minimal_cost([dx1, dy1, dx2, dy2, x, y]) do
    b = div(y * dx1 - x * dy1, dy2 * dx1 - dx2 * dy1)
    a = div(x - b * dx2, dx1)

    cond do
      rem(y * dx1 - x * dy1, dy2 * dx1 - dx2 * dy1) != 0 or b < 0 ->
        :infinity

      rem(x - div(y * dx1 - x * dy1, dy2 * dx1 - dx2 * dy1) * dx2, dx1) != 0 or a < 0 ->
        :infinity

      true ->
        3 * a + b
    end
  end
end

Day13.solution("input_test.txt")
Day13.solution("input.txt")
