defmodule MinBlagoBot.Updaters.TotalReportSender do
  @moduledoc """
    Рассылка сообщения с отчетом с главной страницы бота
  """  
  alias TlgmBot.Repos.User.Schema, as: User
  alias TlgmBot.Repos.User.Api, as: UserApi
  alias MinBlagoBot.Services.MinBlago.ApiFacade, as: Api
  alias MinBlagoBot.Helpers.ReportMessage
  alias TlgmBot.Services.Telegram.Api, as: TelegramApi
  alias TlgmBot.Handlers.Menu
  alias MinBlagoBot.Services.Greeting.Greeting 
  
  use GenWorker,
    run_at: [hour: 9, minute: 00, second: 0],
    run_each: [days: 1],
    timezone: "Europe/Moscow"

  require Logger

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker
    }
  end

  def run(_args) do
    case Api.get_total_report() do
      {:ok, report_data} ->
        send_to_each_user(report_data)
      {:error, reason} ->
        # не делаем ничего, кроме записи в логах
        Logger.error("Не удалось запустить рассылку\n#{inspect(reason)} ")
     end 
  end
  
  defp send_to_each_user(report_data) do
    buttons = Menu.get_menu_buttons("report_sub_menu")
    message = ReportMessage.create_main_report(report_data)
    
    UserApi.listUsers()
    |> Enum.each(fn %User{tlgm_id: id} = user -> 
      Greeting.greeting(user)
      TelegramApi.send_with_buttons(message, id, buttons)
    end)
  end

end
