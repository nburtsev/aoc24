defmodule Day24 do
  def solution(path) do
    [inputs | [gates]] =
      File.read(path)
      |> elem(1)
      |> String.split("\n\n", trim: true)

    # |> IO.inspect()

    inputs =
      inputs
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ": ", trim: true))
      |> Enum.reduce(%{}, fn [name, value], acc ->
        Map.put(acc, name, String.to_integer(value))
      end)

    gates_map = %{
      "AND" => &and_gate/2,
      "OR" => &or_gate/2,
      "XOR" => &xor_gate/2
    }

    gates =
      gates
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, " -> ", trim: true))
      |> Enum.map(fn [gate, output] ->
        [a, gate, b] = String.split(gate, " ", trim: true)

        {a, b, gate, output}
      end)

    values =
      gates
      |> Enum.reduce(%{}, fn {a, b, _, c}, acc ->
        acc = Map.put(acc, a, Map.get(inputs, a))
        acc = Map.put(acc, b, Map.get(inputs, b))
        Map.put(acc, c, Map.get(inputs, c))
      end)

    outputs =
      Map.filter(values, fn {key, _} -> String.starts_with?(key, "z") end)

    :timer.tc(&solve/4, [gates, values, outputs, gates_map], :millisecond) |> IO.inspect()
  end

  def solve(gates, values, outputs, gates_map) do
    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while({values, outputs}, fn _, {values, outputs} ->
      if Map.values(outputs) |> Enum.all?(&(&1 != nil)) do
        {:halt, outputs}
      else
        # go through all gates, if value of a and b are known, calculate the output, write to new_values

        new_values =
          Enum.reduce(gates, %{}, fn {a, b, gate, output}, acc ->
            if Map.get(values, output) != nil do
              Map.put(acc, output, Map.get(values, output))
            else
              if Map.get(values, a) != nil and Map.get(values, b) != nil do
                op = Map.get(gates_map, gate)

                # IO.inspect(
                #   {a, b, output, Map.get(values, a), gate, Map.get(values, b),
                #    op.(Map.get(values, a), Map.get(values, b))},
                #   label: "Performing gate operation"
                # )

                Map.put(acc, output, op.(Map.get(values, a), Map.get(values, b)))
              else
                acc
              end
            end
          end)

        new_values =
          Map.merge(values, new_values)

        new_outputs =
          Map.merge(outputs, Map.filter(values, fn {key, _} -> String.starts_with?(key, "z") end))

        {:cont, {new_values, new_outputs}}
      end
    end)
    |> Enum.sort()
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.reverse()
    |> Enum.join("")
    |> Integer.parse(2)
    |> elem(0)
    |> IO.inspect()
  end

  def and_gate(a, b) do
    if a == 1 and b == 1 do
      1
    else
      0
    end
  end

  def or_gate(a, b) do
    if a == 1 or b == 1 do
      1
    else
      0
    end
  end

  def xor_gate(a, b) do
    if a != b do
      1
    else
      0
    end
  end
end

# Day24.solution("input_test.txt")
Day24.solution("input.txt")
