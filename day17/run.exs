defmodule Day17 do
  def combo_operand(operand, [a, b, c]) do
    case operand do
      0 -> 0
      1 -> 1
      2 -> 2
      3 -> 3
      4 -> a
      5 -> b
      6 -> c
    end
  end

  def adv(operand, [a, b, c]) do
    t = a / 2 ** combo_operand(operand, [a, b, c])

    [floor(t), b, c]
  end

  def bxl(operand, [a, b, c]) do
    [a, Bitwise.bxor(b, operand), c]
  end

  def bst(operand, [a, b, c]) do
    [a, rem(combo_operand(operand, [a, b, c]), 8), c]
  end

  def jnz(operand, [a, b, c]) do
    case a do
      0 -> [a, b, c]
      _ -> operand
    end
  end

  def bxc(_, [a, b, c]) do
    [a, Bitwise.bxor(b, c), c]
  end

  def out(operand, [a, b, c]) do
    {rem(combo_operand(operand, [a, b, c]), 8), [a, b, c]}
  end

  def bdv(operand, [a, b, c]) do
    t = a / 2 ** combo_operand(operand, [a, b, c])

    [a, floor(t), c]
  end

  def cdv(operand, [a, b, c]) do
    t = a / 2 ** combo_operand(operand, [a, b, c])

    [a, b, floor(t)]
  end

  @function_map %{
    0 => &Day17.adv/2,
    1 => &Day17.bxl/2,
    2 => &Day17.bst/2,
    3 => &Day17.jnz/2,
    4 => &Day17.bxc/2,
    5 => &Day17.out/2,
    6 => &Day17.bdv/2,
    7 => &Day17.cdv/2
  }

  def solution(path) do
    input =
      File.read(path)
      |> elem(1)
      |> String.split("\n\n", trim: true)

    [registers, instructions] = input

    [original_a, original_b, original_c] =
      registers
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ": "))
      |> Enum.map(fn [_, value] -> String.to_integer(value) end)
      |> IO.inspect()

    instructions_list =
      instructions
      |> String.split("\n", trim: true)
      |> Enum.at(0)
      |> String.split(": ", trim: true)
      |> Enum.at(1)
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    instructions =
      instructions_list
      |> Enum.chunk_every(2)
      |> IO.inspect()

    # for part 2
    program_output = instructions_list

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while({0, [original_a, original_c, original_c], [], 0}, fn iteration,
                                                                              {pointer, [a, b, c],
                                                                               out, a_value} ->
      if pointer >= length(instructions) do
        {:halt, {Enum.reverse(out), a_value}}
      else
        [opcode, operand] = Enum.at(instructions, pointer)
        instruction = @function_map[opcode]
        res = instruction.(operand, [a, b, c])

        case res do
          [a, b, c] ->
            {:cont, {pointer + 1, [a, b, c], out, a_value}}

          {num, [a, b, c]} ->
            new_output = [num | out]

            desired_output =
              Enum.reverse(Enum.slice(program_output, 0, length(new_output)))

            if new_output != desired_output do
              {:cont,
               {0, [original_a + iteration, original_b, original_c], [], original_a + iteration}}
            else
              {:cont, {pointer + 1, [a, b, c], new_output, a_value}}
            end

          new_pointer ->
            {:cont, {new_pointer, [a, b, c], out, a_value}}
        end
      end
    end)
    |> IO.inspect()
  end
end

Day17.solution("input_test.txt")
Day17.solution("input.txt")
