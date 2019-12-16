defmodule MinBlagoBot.Services.MinBlago.Api do

  alias MinBlagoBot.Services.MinBlago.ReportData
  alias MinBlagoBot.Services.MinBlago.DataPresenter
  alias MinBlagoBot.Services.MinBlago.Cache
  alias MinBlagoBot.Services.MinBlago.ApiFacade

  #redeclaring types
  @type report_atom :: ApiFacade.report_atom
  @type api_result  :: ApiFacade.api_result
  
  @behaviour ApiFacade
  
  require Logger

  # доп параметры есть в урле, но я не использую
  # ?updated_at=1558051200&last_number=0&limit=100"
  @total_report_url   "http://knd.mosreg.ru/api/external/v1/reports/449"
  @planned_report_url "http://knd.mosreg.ru/api/external/v1/reports/415"
  @snow_report_url    "http://knd.mosreg.ru/api/external/v1/reports/416"

  @time_between_requests Application.get_env(:tlgm_bot, :time_between_requests)
  @tries_count 20

  @spec get_total_report() :: api_result
  def get_total_report() do
    Cache.get_report(:total)
  end

  @spec get_planned_report() :: api_result
  def get_planned_report() do
    Cache.get_report(:planned)
  end

  @spec get_snow_report() :: api_result
  def get_snow_report() do
    Cache.get_report(:snow)
  end

  @doc "бурет долбить пока не кончатся попытки"
  @spec get_report_eager(report_atom, non_neg_integer, non_neg_integer) :: api_result()
  def get_report_eager(report_key, try_number \\ 1, total_tries \\ @tries_count)
  def get_report_eager(report_key, try_number, total_tries) when try_number > total_tries do
    msg = "Api request limit reached! stopping request #{inspect(report_key)}"
    Logger.error(msg)

    {:error, msg}
  end

  def get_report_eager(report_key, try_number, total_tries) do
    request_report(report_key) 
    |> decode_api_result() 
    |> log_api_errors()
    |> send_again_or_return(report_key, try_number, total_tries)
  end

  # ============
  # PRIVATE
  # ============
 
  @spec send_again_or_return(api_result, report_atom, non_neg_integer, non_neg_integer) :: {:ok, ReportData.t} 
 
  defp send_again_or_return({:ok, result}, report_key, _, _), do: {:ok, transform_to_report_model(report_key, result)}
  
  defp send_again_or_return({:error, _reason}, report_key, try_number, total_tries) do
        Logger.warn("(Try ##{try_number }/#{total_tries})Report loading failed.\nTrying again in 5 sec...")
        Process.sleep(@time_between_requests)
        get_report_eager(report_key, try_number + 1, total_tries)
  end

  @spec request_report(report_atom) :: {:ok, HTTPoison.Response.t} | {:error, HTTPoison.Error.t}
  defp request_report(report_key) do
    HTTPoison.get(get_url(report_key), [timeout: 10000, recv_timeout: 10000])
  end

  @spec transform_to_report_model(report_atom, [map]) :: ReportData.t
  defp transform_to_report_model(:total, data), do:   data |> DataPresenter.create_model
  defp transform_to_report_model(:planned, data), do: data |> DataPresenter.create_model
  defp transform_to_report_model(:snow, data), do:    data |> DataPresenter.create_snow_model

  @spec decode_api_result({:ok, HTTPoison.Response.t} | {:error, HTTPoison.Error.t}) :: {:ok, [map]} | {:error, binary}
  defp decode_api_result({:ok, %HTTPoison.Response{ body: body, status_code: 200}}) do
    case Poison.decode(body) do
      {:ok, result}    -> {:ok, result }
      {:error, _reason} -> 
        msg = "Ответ апи получен, но не смогли его расшивровать"
        {:error, msg}
    end 
  end

  defp decode_api_result({:ok, %HTTPoison.Response{status_code: status_code}}) when status_code !== 200 do
    msg = "Апи ответил с кодом #{status_code}"
    {:error, msg}
  end

  defp decode_api_result({:error, %HTTPoison.Error{reason: _reason}}) do
    msg = "Ошибка при запросе к АПИ минблаго"
    {:error, msg}
  end

  defp decode_api_result(_result) do
    msg = "Неизвестный результат запроса к апи"
    {:error, msg}
  end


  @spec log_api_errors({:ok, any} | {:error, binary}) :: any
  defp log_api_errors({:ok, _} = result), do: result
  defp log_api_errors({:error, reason} = result) do
    Logger.error(reason) 
    result
  end

  @spec get_url(report_atom) :: binary
  defp get_url(:total),   do: @total_report_url
  defp get_url(:planned), do: @planned_report_url
  defp get_url(:snow),    do: @snow_report_url

end
