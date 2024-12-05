defmodule Day1 do
  def solution(path) do
    {:ok, contents} = File.read(path)

    [rules, updates] =
      contents
      |> String.split("\n\n", trim: true)

    rule_map =
      rules
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn rule, acc ->
        [key, value] = String.split(rule, "|")

        Map.get_and_update(acc, key, fn current_value ->
          case current_value do
            nil -> {value, [value]}
            _ -> {current_value, [value | current_value]}
          end
        end)
        |> elem(1)
      end)

    # part 1
    updates
    |> String.split("\n", trim: true)
    |> Enum.map(fn update -> String.split(update, ",") end)
    |> Enum.filter(&filter_by_rules(&1, rule_map))
    |> Enum.map(&get_middle_element/1)
    |> Enum.reduce(0, &+/2)
    |> IO.inspect()

    # part 2
    updates
    |> String.split("\n", trim: true)
    |> Enum.map(fn update -> String.split(update, ",") end)
    |> Enum.reject(&filter_by_rules(&1, rule_map))
    |> Enum.map(&sort_by_rules(&1, rule_map))
    |> Enum.map(&get_middle_element/1)
    |> Enum.reduce(0, &+/2)
    |> IO.inspect()
  end

  defp get_middle_element(pages) do
    Enum.fetch(pages, round(length(pages) / 2) - 1) |> elem(1) |> String.to_integer()
  end

  defp filter_by_rules(pages, rule_map) do
    pages
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(fn [page1, page2] ->
      rule_map[page1] != nil and Enum.member?(rule_map[page1], page2)
    end)
  end

  defp sort_by_rules(pages, rule_map) do
    pages
    |> Enum.sort(&(rule_map[&1] != nil and Enum.member?(rule_map[&1], &2)))
  end
end

Day1.solution("input_test.txt")
Day1.solution("input.txt")
