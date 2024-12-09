defmodule Day9 do
  def solution(path) do
    {:ok, contents} = File.read(path)

    contents
    |> String.trim()
    |> to_enum()
    |> Enum.filter(&(&1 != nil))
    |> defrag()
    |> checksum()
    |> IO.inspect(charlists: :as_lists)
  end

  defp to_enum(input) do
    input
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.map(fn {element, index} ->
      case rem(index, 2) do
        1 -> List.duplicate(".", element)
        0 -> List.duplicate(trunc(index / 2), element)
      end
    end)
    |> List.flatten()
  end

  def defrag(list) do
    case defrag_helper(list) do
      nil -> list
      updated_list -> defrag(updated_list)
    end
  end

  defp defrag_helper(list) do
    l = Enum.find_index(list, fn x -> x == "." end)
    r = Enum.find_index(Enum.reverse(list), fn x -> x != "." end)

    if l >= length(list) - 1 - r do
      nil
    else
      r = length(list) - 1 - r

      list
      |> List.replace_at(l, Enum.at(list, r))
      |> List.replace_at(r, ".")
    end
  end

  defp checksum(input) do
    Enum.with_index(input)
    |> Enum.reduce(0, fn {id, position}, acc ->
      case id do
        "." -> acc
        _ -> acc + id * position
      end
    end)
  end
end

Day9.solution("input_test.txt")
# Day9.solution("input.txt")
