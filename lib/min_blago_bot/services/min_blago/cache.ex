defmodule MinBlagoBot.Services.MinBlago.Cache do
  @moduledoc "загружает и достает данные из кэш"

  use GenServer

  alias MinBlagoBot.Services.MinBlago.CacheUpdater

  require Logger

  @report_table :api_reports

  # cache ets keys
  @key_total_report   :total
  @key_planned_report :planned
  @key_snow_report    :snow

  def key_total_report,   do: @key_total_report 
  def key_planned_report, do: @key_planned_report
  def key_snow_report,    do: @key_snow_report
  
  def init(state) do
    :ets.new(@report_table, [:set, :private, :named_table])
    
    # вызываем разогрев кеша после инита
    {:ok, state, {:continue, :warmup}}
  end

  ### ================
  # Interface
  ### ================

  def get_report(report_key),   do: GenServer.call(__MODULE__, {:get_report, report_key})
  
  def update_report(data, report_key),   do: GenServer.cast(__MODULE__, {:update, report_key, data}) 

  ### ================
  # Genserver
  ### ================

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def handle_call({:get_report, report_key}, _from, state) do
    {:reply, lookup_report(report_key), state}
  end

  def handle_cast({:update, key, data}, state) do
    update_table(key, data)
    {:noreply, state}
  end

  defp update_table(key, data) do
    :ets.insert(@report_table, {key, data}) 
  end

  def handle_continue(:warmup, state) do
    CacheUpdater.run([])
    {:noreply, state}
  end

  defp lookup_report(report_key) do
    case :ets.lookup(@report_table, report_key)  do
      []       ->
        msg  =  "report key #{inspect(report_key)} not found in cache!"
        Logger.error(msg)
        {:error, :key_not_found_in_cache} 
      [{_key, report}] -> {:ok, report}
    end
  end
end
