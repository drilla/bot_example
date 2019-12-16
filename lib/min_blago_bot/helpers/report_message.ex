defmodule MinBlagoBot.Helpers.ReportMessage do

  alias MinBlagoBot.Services.MinBlago.ReportData

  import TlgmBot.Helpers.Markdown
  import MinBlagoBot.Helpers.Formatter
  import Number.Delimit
  import Number.Percentage

  @date_format "{0D}.{0M}.{YYYY}, {h24}:{m}"

  def create_main_report(%ReportData{} = report_data), do:    create_report("КОНТРОЛЬ ЗА УБОРКОЙ ДВОРОВ", report_data)
  def create_planned_report(%ReportData{} = report_data), do: create_report("СОДЕРЖАНИЕ ДВОРОВ", report_data)
  
  def create_snow_report(%ReportData{snowfall_started: []} = report_data) do
    caption = "УБОРКА ДВОРОВ" |> bold()
    
    caption <>
    "\n" <>
    on_date_section(report_data) <>
    "\n\n" <>
    ("СНЕГОПАДА НЕТ" |> bold)
  end

  def create_snow_report(%ReportData{} = report_data) do
    caption = "УБОРКА ДВОРОВ" |> bold()
    
    caption <>
    "\n" <>
    on_date_section(report_data) <>
    "\n\n" <>
    snowfall_section(report_data) <>
    "\n\n" <>
    yards_section(report_data) <>
    "\n\n" <>
    users_section(report_data) <>
    "\n\n\n" <>
    tasks_section(report_data) <>
    "\n\n\n" <>
    omsu_all_top_section(report_data)
  end

  @doc "сообщение для оповещения я о начавшемся снегопаде"
  @spec create_snow_started([map]) :: binary()
  def create_snow_started(list) do
    text = Enum.map(list, fn %{short_name: name, snowfall_started: _date_time, tasks_total: total} ->
      "\nВ #{name |> String.upcase |> bold} объявлен снегопад."
      <> "\n#{total |> delim |> bold} заданий создано в мобильном приложении в целях ликвидации последствий выпадения осадков."
    end)
    |> Enum.join("\n")
    
    "\u{2757}" <> bold("ВНИМАНИЕ СНЕГОПАД") <> "\u{2757}"
    <> "\n"    <> text
    <> "\n\n"  <> bold("СОТРУДНИКАМ КОММУНАЛЬНЫХ СЛУЖБ НЕОБХОДИМО ОБЕСПЕЧИТЬ УБОРКУ ТЕРРИТОРИИ МУНИЦИПАЛЬНОГО ОБРАЗОВАНИЯ")
 end

 @spec create_snow_time_passed([map]) :: binary
 def create_snow_time_passed(list) when is_list(list) do
  text = Enum.map(list, fn %{
    short_name:        name, 
    snowfall_started:  date_time,

    tasks_not_started: count_not_started,
    tasks_in_work:     count_in_work,
    tasks_completed:   countcompleted,
    
    percent_not_started: percent_not_started,
    percent_in_work:     percent_in_work,
    percent_completed:   percent_completed
    
   } ->
  "В «#{date_time |> Timex.format!("{h24}:{m}") |> bold}» в «#{name |> String.upcase |> bold}» объявлен снегопад.\n"
  <> "\n"
  <> "В течение 2 часов с момента объявления снегопада:\n"
  <> "\n"
  <> "- #{percent_not_started |> number_to_percentage} заданий ( #{count_not_started |> delim} шт. ) не взято в работу\n"
  <> "- #{percent_in_work     |> number_to_percentage} заданий ( #{count_in_work     |> delim} шт. ) находятся в работе\n"
  <> "- #{percent_completed   |> number_to_percentage} заданий ( #{countcompleted    |> delim} шт. ) выполнено"
  end)
  |> Enum.join("\n")
  
  "\u{2757}" <> bold("ВНИМАНИЕ") <> "\u{2757}" <> "\n"
  <> "\n"  
  <> text <> "\n"
  <> "\n"  
  <> bold("СОТРУДНИКАМ КОММУНАЛЬНЫХ СЛУЖБ НЕОБХОДИМО В КРАТЧАЙШИЕ СРОКИ ОБЕСПЕЧИТЬ УБОРКУ ТЕРРИТОРИИ МУНИЦИПАЛЬНОГО ОБРАЗОВАНИЯ")
 end

  # =================
  # PRIVATE
  # =================

  defp create_report(caption, %ReportData{} = report_data) do
    
    (caption |> String.upcase |> bold) <>
    "\n" <>
    on_date_section(report_data) <>
    "\n\n\n" <>
    yards_section(report_data) <>
    "\n\n" <>
    users_section(report_data) <>
    "\n\n\n" <>
    tasks_section(report_data) <>
    "\n\n\n" <>
    omsu_all_top_section(report_data)
  end

  defp snowfall_section(%ReportData{snowfall_started: []}) do
     "СНЕГОПАДА НЕТ" |> bold 
  end

  defp snowfall_section(%ReportData{snowfall_started: snowfalls}) do
    text = snowfalls
    |> Enum.map( fn %{short_name: name, snowfall_started: date_time} ->
         date = Timex.format!(date_time, "{0D}.{0M}.{YYYY}")
         time = Timex.format!(date_time,"{h24}:{m}")
         "#{name |> String.upcase} - #{date |> bold}, в #{time |> bold}" 
       end
      )
      |> Enum.join("\n\n")

      ("ОБЪЯВЛЕН \"СНЕГОПАД\":" |> bold) <> "\n\n#{text}" 
  end

  defp on_date_section(%ReportData{date_time: date_time}) do 
    created = date_time |> Timex.format!(@date_format)
    "по состоянию на: #{created |> bold}"
  end

  defp yards_section(%ReportData{total_yards: total_yards}) do
    yards = total_yards |> delim |> bold

    "Всего объектов (дворы): #{yards}" 
  end

  defp omsu_all_top_section(%ReportData{
    top_omsu_population_200:     top_omsu_population_200,
    top_omsu_population_100_200: top_omsu_population_100_200,
    top_omsu_population_100:     top_omsu_population_100,
  }) do
    ("ТОП ХУДШИХ ОМСУ ПО НЕВЫПОЛНЕННЫМ ЗАДАНИЯМ:" |> bold) <>
    "\n\n\n" <>
    top_omsu_sub_section("БОЛЬШЕ 200 тыс.", top_omsu_population_200) <>
    "\n\n\n" <>
    top_omsu_sub_section("ОТ 100 ДО 200 тыс.", top_omsu_population_100_200) <>
    "\n\n\n" <>
    top_omsu_sub_section("ДО 100 тыс.", top_omsu_population_100)
  end

  defp top_omsu_sub_section(population, []) do
    ("ОМСУ С НАСЕЛЕНИЕМ #{population}" |> bold) <>
    "\n\n" <>
    "ВСЕ ЗАДАНИЯ ВЫПОЛНЕНЫ"
  end

  defp top_omsu_sub_section(population, omsu_list) do
    ("ОМСУ С НАСЕЛЕНИЕМ #{population}" |> bold) <>
    "\n\n" <>
    (
      omsu_list 
      |> omsu_list_to_strings
      |> numbered_list
      |> Enum.join("\n\n")
    )
  end

  defp users_section(%ReportData{
    total_users:          total_users,
    total_workers:        total_workers,
    total_dispatchers:    total_dispatchers,

    active_users:         active_users,
    active_workers:       active_workers,
    active_dispatchers:   active_dispatchers,

    inactive_users:       inactive_users,
    inactive_workers:     inactive_workers,
    inactive_dispatchers: inactive_dispatchers}) do
    "Всего пользователей: #{users_info(total_users, total_workers, total_dispatchers)}, из них:" <>
    "\n\n" <>
    "- активных: #{users_info(active_users, active_workers, active_dispatchers)};" <>
    "\n\n" <>
    "- неактивных: #{users_info(inactive_users, inactive_workers, inactive_dispatchers)}."
  end

  defp tasks_section(%ReportData{
    tasks_total:          tasks_total,
    tasks_completed:      tasks_completed,
    tasks_in_work:        tasks_in_work,
    tasks_failed:         tasks_failed
  }) do
    
    tasks           = tasks_total |> delim |> bold
    tasks_completed = tasks_completed |> delim |> bold
    tasks_in_work   = tasks_in_work |> delim |> bold
    tasks_failed    = tasks_failed |> delim |> bold

     "Всего заданий: #{tasks}, из них:" <>
    "\n\n" <>
    "- выполнено: #{tasks_completed};" <>
    "\n\n" <>
    "- в работе: #{tasks_in_work};" <>
    "\n\n" <>
    "- не выполнено: #{tasks_failed}."

  end

  defp omsu_list_to_strings(omsu_list) do
    Enum.map(omsu_list, &omsu_to_string(&1))
  end

  defp omsu_to_string(%{
    short_name: name,
    tasks_total: total,
    tasks_failed: count,
    percent_failed: percent
    }) do
    "#{ name |> String.upcase } - #{count |> delim |> bold} из #{total |> delim |> bold} / #{percent |> number_to_percentage |> bold}"
  end

  defp users_info(users_count, workers_count, dispatchers_count) do
    users       = users_count       |> delim |> bold
    workers     = workers_count     |> delim |> bold
    dispatchers = dispatchers_count |> delim |> bold
    "#{users} (#{workers} исполнителей, #{dispatchers} диспетчеров)"
  end

  #shortcut to external method
  defp delim(number), do: number_to_delimited(number)
end