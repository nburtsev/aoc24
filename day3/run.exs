defmodule Day1 do
  def solution(path) do
    {:ok, contents} = File.read(path)

    result = find_execute_and_sum_muls(contents)
    IO.inspect(result)

    result2 =
      Regex.replace(~r/don't\(\)(.*?)do\(\)/s, contents, "", global: true)
      |> find_execute_and_sum_muls

    IO.inspect(result2)
  end

  defp find_execute_and_sum_muls(contents) do
    Regex.scan(~r/mul\(\d+,\d+\)/, contents)
    |> Enum.map(fn [match] -> Regex.scan(~r/\d+/, match) end)
    |> Enum.map(fn [[a], [b]] -> String.to_integer(a) * String.to_integer(b) end)
    |> Enum.sum()
  end
end

Day1.solution("input_test.txt")
Day1.solution("input.txt")
