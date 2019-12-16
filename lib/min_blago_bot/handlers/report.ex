defmodule MinBlagoBot.Handlers.Report do
  use GenServer
  use TlgmBot.TlgmHandler
  use TlgmBot.TlgmHandler.Init

  alias MinBlagoBot.Helpers.ReportMessage
  alias MinBlagoBot.Helpers.ErrorMessage
  alias MinBlagoBot.Services.MinBlago.ApiFacade, as: Api

  alias TlgmBot.Services.Telegram.ApiFacade, as: TelegramApi
  alias TlgmBot.Helpers.Buttons
  alias TlgmBot.Handlers.Menu

  @module_name "report"

  def name, do: @module_name
  def get_cmd, do: @module_name

  @action_report  "report"
  @action_planned "planned"
  @action_snow    "snow" 

  def action_report, do: @action_report
  def action_planned, do: @action_planned
  def action_snow, do: @action_snow

  def handle_message(%TlgmMessage{
    msg: msg,
    action: action
    }, state) do
 
    chat_id = TelegramApi.getChatId(msg)
    buttons = create_buttons(action)
    
    case get_report_data(action) do
      {:ok, report_data} ->
        report_data
        |> create_message(action)
        |> TelegramApi.send_with_buttons(chat_id, buttons)
      {:error, _} ->
        ErrorMessage.error()
        |> TelegramApi.sendMessage(chat_id)
    end 
    
   {:noreply, state}
  end

  defp get_report_data(@action_report),  do: Api.get_total_report() 
  defp get_report_data(@action_planned), do: Api.get_planned_report()
  defp get_report_data(@action_snow),    do: Api.get_snow_report()

  defp create_message(data, @action_report), do: ReportMessage.create_main_report(data)
  defp create_message(data, @action_planned), do: ReportMessage.create_planned_report(data)
  defp create_message(data, @action_snow), do: ReportMessage.create_snow_report(data)

  defp create_buttons(@action_report),  do: Menu.get_menu_buttons("report_sub_menu")
  defp create_buttons(@action_planned), do: Buttons.create_single_row_button(@module_name, @action_report, nil, "НАЗАД")
  defp create_buttons(@action_snow),    do: Buttons.create_single_row_button(@module_name, @action_report, nil, "НАЗАД")
end