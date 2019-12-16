defmodule MinBlagoBot.Services.MinBlago.DataPresenter do
  alias MinBlagoBot.Services.MinBlago.ReportData
  
  def create_model(list) do
    atomized_list = Enum.map(list, &atomize_keys(&1))
    
    atomized_list
    |> summary
    |> add_omsu_rating(atomized_list)
    |> add_datetime()
  end

  def create_snow_model(list) do
    atomized_list = Enum.map(list, &atomize_keys(&1))
    
    atomized_list 
    |> snowfall_only
    |> create_model
    |> add_snowfall_data(atomized_list)
  end

  # =================
  # PRIVATE
  # =================
  
  # суммирует значения омсу в общую модель
  defp summary(list) do
    list
    |> Enum.reduce( %ReportData{}, fn ( %{} = item, %ReportData{} = acc) -> 
      %ReportData{
        total_yards:          to_zero(acc.total_yards) + item.total_yards,
        total_users:          to_zero(acc.total_users) + item.total_users,
        total_workers:        to_zero(acc.total_workers) + item.total_workers,
        total_dispatchers:    to_zero(acc.total_dispatchers) + item.total_dispatchers,
        active_users:         to_zero(acc.active_users) + item.active_users,
        active_workers:       to_zero(acc.active_workers) + item.active_workers,
        active_dispatchers:   to_zero(acc.active_dispatchers) + item.active_dispatchers,
        inactive_users:       to_zero(acc.inactive_users) + item.inactive_users,
        inactive_workers:     to_zero(acc.inactive_workers) + item.inactive_workers,
        inactive_dispatchers: to_zero(acc.inactive_dispatchers) + item.inactive_dispatchers,
        tasks_total:          to_zero(acc.tasks_total) + item.tasks_total,
        tasks_completed:      to_zero(acc.tasks_completed) + item.tasks_completed,
        tasks_in_work:        to_zero(acc.tasks_in_work) + item.tasks_in_work,
        tasks_failed:         to_zero(acc.tasks_failed) + item.tasks_failed,
      }
    end) 
  end

  defp add_snowfall_data(%ReportData{} = report_data, list) do
    report_data
    |> Map.replace!(:snowfall_started, to_snowfall_list(list))
  end

  defp to_snowfall_list(list) do
   list
   |> snowfall_only
   |> Enum.map(&add_not_started(&1))
   |> Enum.map(&add_percent_failed(&1))
   |> Enum.map(&add_percent_in_work(&1))
   |> Enum.map(&add_percent_completed(&1))
   |> Enum.map(&snowfall_started_to_datetime(&1))
  end

  defp snowfall_started_to_datetime(%{snowfall_started: timestamp} = item) do
    Map.replace!(item, :snowfall_started, timestamp |> DateTime.from_unix! |> Timex.local)
  end

  defp snowfall_only(list) do
    Enum.filter(list, fn %{snowfall_started: value} -> value != -1 end)
  end

  defp add_omsu_rating(%ReportData{} = report_data, list) do
    report_data 
    |> Map.replace!(:top_omsu_population_200, get_over_200_pop(list))
    |> Map.replace!(:top_omsu_population_100_200, get_100_200_pop(list))
    |> Map.replace!(:top_omsu_population_100, get_below_100_pop(list))
  end

  defp get_over_200_pop(list), do:  get_by_population(list, 1) 
  defp get_100_200_pop(list), do:  get_by_population(list, 2) 
  defp get_below_100_pop(list), do:  get_by_population(list, 3) 
  
  defp get_by_population(list, type) do
    list
    |> Enum.filter(fn %{population_type: item_type} -> item_type === type end)
    |> Enum.filter(fn %{tasks_failed: failed} -> failed > 0 end)
    |> Enum.map(&add_percent_failed(&1))
    |> Enum.sort_by(fn %{percent_failed: percent} -> percent end, &>=/2)
    |> Enum.take(3)
  end

  defp add_datetime(%ReportData{} = data), do:  Map.replace!(data, :date_time, Timex.local())

  defp to_zero(nil), do: 0
  defp to_zero(val) when is_integer(val), do: val

  defp atomize_keys(%{} = map) do
    map |> Map.new(fn {k, v} ->
      cond do
         is_atom(k) -> {k, v}
         true       -> {String.to_atom(k), v} 
      end 
    end)
  end

  defp percent(0, _part), do: 0
  defp percent(total, part) do
    part / total * 100
  end

  defp add_percent_failed(%{tasks_total: total, tasks_failed: failed} = item) do
    Map.merge(item, %{percent_failed: percent(total, failed)})
  end  
  
  defp add_not_started(%{tasks_total: total} = item) do
    not_started_count = calc_not_started_tasks_count(item)
    item
    |> Map.merge(%{tasks_not_started: not_started_count })
    |> Map.merge(%{percent_not_started: percent(total, not_started_count)})
  end 

  defp add_percent_completed(%{tasks_total: total, tasks_completed: completed} = item) do
    Map.merge(item, %{percent_completed: percent(total, completed)})
  end
  
  defp add_percent_in_work(%{tasks_total: total, tasks_in_work: in_work} = item) do
    Map.merge(item, %{percent_in_work: percent(total, in_work)})
  end
  
  defp calc_not_started_tasks_count(%{
    tasks_total: total,
    tasks_completed: completed,
    tasks_in_work: in_work,
    tasks_failed: failed
    }) do 
      total - (completed + in_work + failed)
  end
end
