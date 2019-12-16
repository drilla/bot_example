defmodule MinBlagoBot.Services.Greeting.Greeting do


  alias MinBlagoBot.Services.Greeting.LastInteraction
  alias MinBlagoBot.Services.Greeting.Message, as: GreetingHelper
  alias TlgmBot.Repos.User.Schema, as: User
  alias TlgmBot.Services.Telegram.Api, as: TelegramApi
  
  @doc "будет выслано приветствие, если этот юзер не взаимодействовал на текущий день с ботом"
  def greeting(%User{tlgm_id: id} = user) do
    last_date = LastInteraction.get_last(id)

    unless is_same_day?(last_date) do
        GreetingHelper.create_message(user)
        |> TelegramApi.sendMessage(id)
        |> update_interaction(id)

      :yes
    else
      :no
    end
  end

  defp is_same_day?(%DateTime{} = date_time) do
    now = Timex.local()
    #TODO potential error - if different month and same days
    today_day     = now       |> Timex.format!("{D}") |> String.to_integer()
    last_call_day = date_time |> Timex.format!("{D}") |> String.to_integer()
    
    today_day === last_call_day
  end

  defp is_same_day?(_), do: false

  defp update_interaction({:ok, _}, id), do: LastInteraction.update(id)
  defp update_interaction(_, _),         do: nil
end