defmodule Tablature do
  def parse(tab) do
  tab
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, row_idx} ->
      [label, content | _] = String.split(line, "|")

      content
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reject(fn {char, _} -> char =~ ~r/\D/ end)
      |> Enum.map(fn {digit, col_idx} ->
        {col_idx, row_idx, "#{label}#{digit}"}
      end)
    end)
    |> Enum.sort()
    |> Enum.map(fn {_, _, note} -> note end)
    |> Enum.join(" ")
  end
end
