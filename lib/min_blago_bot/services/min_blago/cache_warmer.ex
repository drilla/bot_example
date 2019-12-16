defmodule MinBlagoBot.Services.MinBlago.CacheWarmer do
  @moduledoc "Cache warming up"

  require Logger
  
  import Logger, only: [info: 1]

  alias MinBlagoBot.Services.MinBlago.Cache
  alias MinBlagoBot.Services.MinBlago.ApiFacade, as: Api 
 
  def run() do
    # перевести на асинхрон!
    load_report(Cache.key_total_report)
    load_report(Cache.key_planned_report)
    load_report(Cache.key_snow_report)
    Logger.info( "Cache warmed up.")

    # когда научусь читать опции

    # case OptionParser.parse(["--fill_cache"], strict: [fill_cache: :boolean]) |>  IO.inspect do
      # {[debug: true], [], []} ->
        # AlertSender.fill_cache_only()
          # Logger.error("run!")
          # res  -> Logger.warn(res)
    # end
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
    info "Report loaded!"
  end
end
