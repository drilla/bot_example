defmodule MinBlagoBot.Services.MinBlago.CacheUpdater do
  @moduledoc """
  Ротатор логов.
  Так как динамически менять дату лога не получается. То этот модуль раз в день бэкапи текущий лог
  """

  require Logger
  import Logger, only: [info: 1]

  use GenWorker,
    run_each: [minutes: Application.get_env(:tlgm_bot, :cache_update_frequency)],
    timezone: "Europe/Moscow"

  alias MinBlagoBot.Services.MinBlago.Cache
  alias MinBlagoBot.Services.MinBlago.ApiFacade, as: Api
  
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker
    }
  end

  def run(_args) do
    info "Updating Cache..."
    load_report(Cache.key_total_report)
    load_report(Cache.key_planned_report)
    load_report(Cache.key_snow_report)
  end

  defp load_report(report_key) do
    info "loading #{report_key} report ... "
    Api.get_report_eager(report_key)
    |> update_cache(report_key)
  end

  defp update_cache({:error, _reason}, report_key) do
    Logger.error("Report cache was not updated! report: #{report_key}")
  end
  
  defp update_cache({:ok, result}, report_key) do
    Cache.update_report(result, report_key)
    info "Report updated!"
  end
end
