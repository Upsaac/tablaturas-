defmodule Tablature do
  def parse(tab) do
    tab
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn segment ->
      segment
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [string | parts] = String.split(line, "|")
        parts = Enum.reject(parts, fn x -> x == "" end)

        Enum.map(parts, fn notes ->
          String.graphemes(notes)
          |> Enum.map(fn c ->
            if c =~ ~r/\d/ do
              "#{String.trim(string)}#{c}"
            else
              ""
            end
          end)
        end)
      end)
      |> Enum.zip()
      |> Enum.flat_map(fn measure ->
        measure
        |> Tuple.to_list()
        |> Enum.zip()
        |> Enum.map(fn tuple ->
          tuple
          |> Tuple.to_list()
          |> Enum.filter(fn x -> x != "" end)
          |> Enum.join("/")
        end)
        |> Enum.chunk_by(fn x -> x == "" end)
        |> Enum.flat_map(fn group ->
          if hd(group) == "" and length(group) >= 3 do
            count = div(length(group) + 2, 3)  # ceil(length/3)
            List.duplicate("_", count)
          else
            Enum.reject(group, fn x -> x == "" end)
          end
        end)
      end)
      |> Enum.join(" ")
    end)
    |> Enum.join(" ")
  end
end
