defmodule Test.Mock.TelegramApi do
  @behaviour TlgmBot.Services.Telegram.ApiFacade
  
  require Logger

  def sendMessage(msg, chId, parse_mode \\ :Markdown, markup \\ %{})
  def sendMessage(msg, _chId, _parse_mode, _markup) do
    log_msg(msg)
    {:ok, %Nadia.Model.Message{}}
  end

  def send_with_buttons(msg, chat_id, buttons) do
    sendMessage(
      msg,
      chat_id,
      :Markdown,
      %{inline_keyboard: buttons}
    )
  end

  def edit_message(_msg, text, _buttons), do: log_msg(text);{:ok, %Nadia.Model.Message{}}
  def splitAndSend(str, _chId),           do: log_msg(str); :ok

  def getUser(_msg),        do: %Nadia.Model.User{}
  def get_date_time(_msg),  do: Timex.local()
  def getChatId(_msg),      do: 1
  def get_message_id(_msg), do: 1

  defp log_msg(msg) do
    Logger.debug("Отправлено сообщение в телегу")
    Logger.debug(msg)
    msg
  end
end