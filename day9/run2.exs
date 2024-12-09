defmodule Day9 do
  def solution(path) do
    {:ok, contents} = File.read(path)

    contents
    |> String.trim()
    |> to_enum()
    |> Enum.filter(&(&1 != []))
    |> IO.inspect(charlists: :as_lists)
    |> defrag()
    # |> List.flatten()
    # |> checksum()
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
  end

  def defrag(list) do
    case defrag_helper(list) do
      nil -> list
      updated_list -> defrag(updated_list)
    end
  end

  defp defrag_helper(list) do
    # dots group
    l = Enum.find_index(list, fn x -> Enum.at(x, 0) == "." end)
    # numbers group
    r =
      Enum.find_index(Enum.reverse(list), fn x ->
        Enum.at(x, 0) != "." and length(x) <= length(Enum.at(list, l))
      end)

    r = length(list) - 1 - r

    if l >= r do
      nil
    else
      to_insert = Enum.at(list, r)
      to_move = List.duplicate(".", length(to_insert))
      to_insert_right = List.duplicate(".", length(Enum.at(list, l)) - length(to_insert))
      IO.inspect({to_insert, to_move, to_insert_right}, charlists: :as_lists)

      list
      |> List.replace_at(l, to_insert)
      |> List.insert_at(l + 1, to_insert_right)
      |> List.replace_at(r + 1, to_move)
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
