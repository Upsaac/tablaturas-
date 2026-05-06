defmodule Tablature do
  def parse(tab) do
    lines = String.split(tab, "\n", trim: true)

    # 1. Extracción de Coordenadas y Barras de Compás
    {notes, bars} =
      Enum.with_index(lines)
      |> Enum.reduce({[], MapSet.new()}, fn {line, row_idx}, {n_acc, b_acc} ->
        [label, content | _] = String.split(line, "|", parts: 2)

        # Escaneamos la línea para identificar notas y posiciones de los '|'
        content
        |> String.graphemes()
        |> Enum.with_index(String.length(label) + 1)
        |> Enum.reduce({n_acc, b_acc}, fn {char, col_idx}, {inner_n, inner_b} ->
          cond do
            char =~ ~r/\d/ -> {[{col_idx, row_idx, "#{label}#{char}"} | inner_n], inner_b}
            char == "|" -> {inner_n, MapSet.put(inner_b, col_idx)}
            true -> {inner_n, inner_b}
          end
        end)
      end)

    # 2. Procesamiento de la Línea de Tiempo
    notes
    |> Enum.group_by(fn {col, _, _} -> col end)
    |> Enum.sort()
    |> Enum.chunk_every(2, 1, [nil]) # Comparamos pares de eventos consecutivos
    |> Enum.flat_map(fn
      [{col1, group1}, {col2, _group2}] ->
        #Evaluamos si hay un silencio entre eventos
        # Solo si la distancia es >= 4 y NO hay una barra '|' en medio
        if col2 - col1 >= 4 and not bar_between?(bars, col1, col2) do
          [format_group(group1), "_"]
        else
          [format_group(group1)]
        end

      [{_col1, group1}, nil] ->
        [format_group(group1)]
    end)
    |> Enum.join(" ")
  end

  defp format_group(notes) do
    notes
    |> Enum.sort_by(fn {_, row, _} -> row end)
    |> Enum.map(fn {_, _, val} -> val end)
    |> Enum.join("/")
  end

  defp bar_between?(bars, c1, c2) do
    Enum.any?(bars, fn b_pos -> b_pos > c1 and b_pos < c2 end)
  end
end
