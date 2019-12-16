defmodule MinBlagoBot.Services.MinBlago.ApiFacade do
  
  @type api_result :: {:ok, ReportData.t} | {:error, binary}
  @type report_atom :: :total | :planned | :snow

  @callback get_total_report()   :: api_result
  @callback get_planned_report() :: api_result
  @callback get_snow_report()    :: api_result
  @callback get_report_eager(report_atom)                                   :: api_result 
  @callback get_report_eager(report_atom, non_neg_integer, non_neg_integer) :: api_result 
  
  @spec get_total_report() :: api_result
  def get_total_report(), do: get_module().get_total_report() 
  
  @spec get_planned_report() :: api_result
  def get_planned_report(), do: get_module().get_planned_report() 
  
  @spec get_snow_report() :: api_result
  def get_snow_report(), do: get_module().get_snow_report()
  
  @doc "бурет долбить пока не кончатся попытки"
  @spec get_report_eager(report_atom)                                   :: api_result 
  @spec get_report_eager(report_atom, non_neg_integer, non_neg_integer) :: api_result 
  
  def get_report_eager(report_key),                          do: get_module().get_report_eager(report_key) 
  def get_report_eager(report_key, try_number, total_tries), do: get_module().get_report_eager(report_key, try_number, total_tries) 
  
  defp get_module(), do: Application.get_env(:tlgm_bot, :minblago_api_module)
end
