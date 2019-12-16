defmodule MinBlagoBot.Helpers.Formatter do
  @moduledoc "форматирует данные для сообщений"


  @doc "нуменованый список из набора строк"

  def numbered_list(list, start \\ 1) do
    list
    |> Enum.with_index()
    |> Enum.map(fn({text, index}) ->

      "#{start + index}. #{text}"
    end
       )
  end

  def to_money(number, sign \\ nil)
  def to_money(%Decimal{} = number, nil) do
    Decimal.round(number, 2) |> Number.Delimit.number_to_delimited()
  end
  def to_money(%Decimal{} = number, sign) when is_binary(sign) do
    "#{to_money(number)} #{sign}"
  end

  def rid_spaces(string), do: String.replace(string, " ", "")
end
