defmodule MinBlagoBot.Services.Greeting.Message do
  @moduledoc """
      Только приветственное сообщение.
  """
  
  alias TlgmBot.Repos.User.Schema, as: User 

  @name "RM: МинБлаго: Контроль"
  def create_message(
         %User{
           name: fName,
           #last_name: lName,
           username: uName
         }
       ) do

        h = Timex.local() |> Timex.format!("{h24}") |> String.to_integer()
        
    "*#{get_name(fName, uName)}*, #{get_msg_by_hours(h)}!\n\n" <>
    "Я ваш электронный помощник *«#{@name}».*\n\n" <>
    "Я могу помочь вам узнать об уборке дворов в Московской области\n\n"
  end

  defp get_name(nil, nil), do: "Пользователь"
  defp get_name(nil, login), do: login
  defp get_name(fName, _login), do: fName

  defp get_msg_by_hours(h) when h >= 4 and h < 10, do: "доброе утро"
  defp get_msg_by_hours(h) when h >= 10 and h < 16, do: "добрый день"
  defp get_msg_by_hours(h) when h >= 16 and h < 22, do: "добрый вечер"
  defp get_msg_by_hours(h) when h >= 22 or h < 4, do: "доброй ночи"

  defp get_last_call_time(tId) when is_binary(tId), do: tId |> String.to_integer |> get_last_call_time
  defp get_last_call_time(tId) do
    case :ets.lookup(:last_call, tId) do
      [] -> nil 
      [{_, last_call_time}] -> last_call_time
    end
  end

end
