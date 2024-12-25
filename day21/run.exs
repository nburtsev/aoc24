defmodule Day21 do
  @directions [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]

  @keypad %{
    "7" => {0, 0},
    "8" => {1, 0},
    "9" => {2, 0},
    "4" => {0, 1},
    "5" => {1, 1},
    "6" => {2, 1},
    "1" => {0, 2},
    "2" => {1, 2},
    "3" => {2, 2},
    "0" => {1, 3},
    "A" => {2, 3}
  }

  @controls %{
    {1, 0} => "^",
    {2, 0} => "A",
    {0, 1} => "<",
    {1, 1} => "v",
    {2, 1} => ">"
  }

  def solution(path) do
    input =
      File.read(path)
      |> elem(1)
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)
      |> IO.inspect()

    # robot 1 starts at keypad[A]

    start_keypad = {2, 3}
    start_proxy1 = {2, 0}
    start_proxy2 = {2, 0}

    keypad_graph = [{2, 3}]
  end
end

# Mix.install([{:heap, "~> 3.0.0"}])
Day21.solution("input_test.txt")
# Day21.solution("input.txt")
