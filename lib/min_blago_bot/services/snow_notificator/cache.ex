defmodule MinBlagoBot.Services.SnowNotificator.Cache do
  @moduledoc "загружает и достает данные из кэш для нотификатора"

  use GenServer

  require Logger

  #Важно! поскольку данные сохраняются между сессиями, нельзя использовать одну таблицу для все энв
  @table_started     :"#{Mix.env()}_notified_about_start"
  @table_time_passed :"#{Mix.env()}_notified_about_time_passed"

  @dets_dir               Application.get_env(:tlgm_bot, :dets_dir)
  @table_started_file     :"#{@dets_dir}/#{@table_started}"
  @table_time_passed_file :"#{@dets_dir}/#{@table_time_passed}"

  def init(state) do
    Process.flag(:trap_exit, true)

    :dets.open_file(@table_started,     [type: :set, auto_save: :infinity, ram_file: true, file: @table_started_file])
    :dets.open_file(@table_time_passed, [type: :set, auto_save: :infinity, ram_file: true, file: @table_time_passed_file])

    {:ok, state}
  end
  
  ### ================
  # Interface
  ### ================

  def only_not_notified_about_start(items) when is_list(items), do: Enum.filter(items, &(not is_notified_about_start?(&1)))
  def only_not_notified_time_passed(items) when is_list(items), do: Enum.filter(items, &(not is_notified_time_passed?(&1)))
  
  def is_notified_about_start?(%{} = item), do: GenServer.call(__MODULE__, {:in_cache, @table_started, item})
  def is_notified_time_passed?(%{} = item), do: GenServer.call(__MODULE__, {:in_cache, @table_time_passed, item})
  
  def remove_obsolete_started(actual)     when is_list(actual), do: GenServer.cast(__MODULE__,  {:remove_obsolete, @table_started, actual})
  def remove_obsolete_time_passed(actual) when is_list(actual), do: GenServer.cast(__MODULE__,  {:remove_obsolete, @table_time_passed, actual})
  
  def add_notified_about_start(list), do: GenServer.cast(__MODULE__, {:add, @table_started, list}) 
  def add_notified_time_passed(list), do: GenServer.cast(__MODULE__, {:add, @table_time_passed, list}) 

  def clear_started(),     do: GenServer.cast(__MODULE__, {:clear, @table_started})
  def clear_time_passed(), do: GenServer.cast(__MODULE__, {:clear, @table_time_passed})

  ### ================
  # Genserver
  ### ================

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def handle_call({:in_cache, table_name, item}, _from, state) do
    {:reply, has_in_table?(table_name, item), state}
  end

  def handle_cast({:add, table_name, to_add_list}, state) do
    update(table_name, to_add_list)
    {:noreply, state}
  end

  def handle_cast({:remove_obsolete, table_name, actual_list}, state) do
    actual_keys = 
      actual_list |> Enum.map(&generate_key(&1))

    keys_in_table = get_all_keys(table_name)

    obsolete_keys = keys_in_table -- actual_keys

    delete_keys(table_name, obsolete_keys)
    
    {:noreply, state}
  end

  def handle_cast({:update, table_name, items_list}, state) do
    update(table_name, items_list)
    {:noreply, state}
  end

  def handle_cast({:clear, table_name}, state) do
    clear_table(table_name)
    {:noreply, state}
  end

  def handle_info({:EXIT, _from, reason}, state) do
    close_tables()
    {:stop, reason, state} 
  end

  def terminate, do: close_tables()
  
  # ====================
  # PRIVATE
  # ====================

  defp update(table, items) when is_list(items) do
    items
    |> Enum.each(fn item -> 
      key = generate_key(item)
      :dets.insert(table, {key, true}) 
    end)
    
    :dets.sync(table)
  end
  
  defp update(table, item), do: update(table, [item])
  
  defp get_all_keys(table) do
    first = :dets.first(table)
    get_keys(table, first, [])  
  end
  
  defp get_keys(_table, :"$end_of_table", acc), do: acc
  
  defp get_keys(table, prev_key, acc) when is_tuple(prev_key) do
    next = :dets.next(table, prev_key)
    get_keys(table, next, [prev_key | acc])
  end

  defp has_in_table?(table, item) do
    key = generate_key(item)

    :dets.member(table, key)
  end

  defp delete_keys(table, keys) when is_list(keys) do
    Enum.each(keys, &:dets.delete(table,&1))

    :dets.sync(table)
  end

  defp close_tables do
    :dets.close(@table_started)
    :dets.close(@table_time_passed)
  end

  defp clear_table(table_name) do
     :dets.delete_all_objects(table_name)
     :dets.sync(table_name)
  end

  defp generate_key(%{short_name: short_name, snowfall_started: date_time}) do
    ts = DateTime.to_unix(date_time)
    name = :crypto.hash(:md5, short_name) |> Base.encode16()

    {name, ts}
  end
end