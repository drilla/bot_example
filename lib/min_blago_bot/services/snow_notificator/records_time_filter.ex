defmodule MinBlagoBot.Services.SnowNotificator.RecordsTimeFilter do
  @moduledoc """
    фильтрует записи по временным условиям
  """
  
  def only_time_passed(list, hours), do: only_time_passed(list, hours, Timex.local())
  def only_time_passed(list, hours, from_time) do
    Enum.filter(list, fn %{snowfall_started: date_time} ->
      moment_when_time_is_out = date_time |> Timex.shift(hours: hours)
      from_time > moment_when_time_is_out
    end)
  end

  def not_too_old(list, hours), do: not_too_old(list, hours, Timex.local())
  def not_too_old(list, hours, from_time) do
    Enum.filter(list, fn %{snowfall_started: date_time} ->
      moment_when_time_is_out = date_time |> Timex.shift(hours: hours)
      from_time < moment_when_time_is_out
    end)
  end
end
