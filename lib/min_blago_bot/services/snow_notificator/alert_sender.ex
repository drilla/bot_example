defmodule MinBlagoBot.Services.SnowNotificator.AlertSender do
  @moduledoc """
    Рассылка сообщений:
    - о наступлении снегопада
    - через определенное время после наступления
  """
  alias MinBlagoBot.Services.MinBlago.ApiFacade, as: Api
  alias MinBlagoBot.Helpers.ReportMessage
  alias TlgmBot.Services.Telegram.ApiFacade, as: TelegramApi

  alias MinBlagoBot.Services.SnowNotificator.Cache
  alias MinBlagoBot.Services.SnowNotificator.RecordsTimeFilter
  alias MinBlagoBot.Services.MinBlago.ReportData
  
  @notify_after_hours 2

  use GenWorker,
    run_each: [minutes: 1],
    timezone: "Europe/Moscow"

  require Logger

  @channel_id Application.get_env(:tlgm_bot, :channel_id)

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker
    }
  end

  def run(_args) do
    case Api.get_snow_report() do
      {:ok, report_data} ->
        process_new_snowfalls(report_data)
        process_after_time(report_data)

      {:error, _reason} ->
        Logger.error("Не удалось запустить рассылку уведомлений о новых снегопадах")
    end
  end

  # только наполнить кэш, без отсылки. для тихого запуска приложения. Сообщения не будут учтены
  def fill_cache_only() do
    case Api.get_snow_report() do
      {:ok, %ReportData{snowfall_started: items}} ->
        items 
        |> Cache.add_notified_about_start()
        
        items 
        |> RecordsTimeFilter.only_time_passed(@notify_after_hours) #данные за последнее время не запихиваем, они сами должны зайти в процессе работы
        |> Cache.add_notified_time_passed
      {:error, _reason} ->
        Logger.error("Не удалось наполнить кэш ПОЛНЫМИ данными новых снегопадах")
      end
  end

  defp process_new_snowfalls(%ReportData{snowfall_started: snowfall_list}) do
    snowfall_list
    |> Cache.only_not_notified_about_start()
    |> send_notifications_about_start()
    |> Cache.add_notified_about_start()

    Cache.remove_obsolete_started(snowfall_list)
  end

  defp process_after_time(%ReportData{snowfall_started: snowfall_list}) do
    snowfall_list
    |> RecordsTimeFilter.only_time_passed(@notify_after_hours)             # выбираем все записи, которые лежат более указанного времени
    |> Cache.only_not_notified_time_passed()
    |> send_notifications_time_passed()
    |> Cache.add_notified_time_passed()

    Cache.remove_obsolete_time_passed(snowfall_list)
  end

  defp send_notifications_about_start([]), do: []

  defp send_notifications_about_start(new_snowfalls) do
    ReportMessage.create_snow_started(new_snowfalls)
    |> TelegramApi.sendMessage(@channel_id)

    new_snowfalls
  end

  defp send_notifications_time_passed([]), do: []

  defp send_notifications_time_passed(new_snowfalls) do
    ReportMessage.create_snow_time_passed(new_snowfalls)
    |> TelegramApi.sendMessage(@channel_id)

    new_snowfalls
  end
end
