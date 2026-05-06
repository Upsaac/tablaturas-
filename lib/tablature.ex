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
    # Agrupamos notas que comparten la misma columna
    |> Enum.group_by(fn {col, _row, _val} -> col end)
    # Ordenamos las cubetas por tiempo
    |> Enum.sort()
    |> Enum.map(fn {_col_idx, notes_in_column} ->
      notes_in_column
      |> Enum.sort_by(fn {_col, row, _val} -> row end) # Ordenar cuerdas: e, B, G...
      |> Enum.map(fn {_, _, val} -> val end)
      |> Enum.join("/") # Unimos notas simultáneas
    end)

    |> Enum.join(" ")

  end
end
