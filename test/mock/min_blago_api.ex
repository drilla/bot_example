defmodule Tests.Mock.MinBlagoApi do

alias MinBlagoBot.Services.MinBlago.ReportData
  @behaviour MinBlagoBot.Services.MinBlago.ApiFacade
  
  def get_total_report() do
    {:ok, %ReportData{}} 
  end

  def get_planned_report() do
    {:ok, %ReportData{}} 
  end

  def get_snow_report() do
    data = %ReportData{
   active_dispatchers: 2,
   active_users: 14,
   active_workers: 12,
   date_time: Timex.local |> Timex.shift(minutes: -3), 
   inactive_dispatchers: 0,
   inactive_users: 59,
   inactive_workers: 59,
   snowfall_started: [
     %{
       active_dispatchers: 2,
       active_users: 14,
       active_workers: 12,
       created_at: 1576429477,
       id: 13453,
       inactive_dispatchers: 0,
       inactive_users: 59,
       inactive_workers: 59,
       omsu_id: 13453,
       percent_completed: 37.5366568914956,
       percent_failed: 53.27468230694037,
       percent_in_work: 9.188660801564028,
       percent_not_started: 0.0,
       population_type: 1,
       primary_key: "13453",
       short_name: "Красногорск, г.о.",
       snowfall_started: Timex.local |> Timex.shift(hours: -3), 
       snowfall_status: "Уборка снегопада",
       tasks_completed: 384,
       tasks_failed: 545,
       tasks_in_work: 94,
       tasks_not_started: 0,
       tasks_total: 1023,
       total_dispatchers: 2,
       total_users: 73,
       total_workers: 71,
       total_yards: 342,
       updated_at: 1576429477
     }
   ],
   tasks_completed: 384,
   tasks_failed: 545,
   tasks_in_work: 94,
   tasks_total: 1023,
   top_omsu_population_100: [],
   top_omsu_population_100_200: [],
   top_omsu_population_200: [
     %{
       active_dispatchers: 2,
       active_users: 14,
       active_workers: 12,
       created_at: 1576429477,
       id: 13453,
       inactive_dispatchers: 0,
       inactive_users: 59,
       inactive_workers: 59,
       omsu_id: 13453,
       percent_failed: 53.27468230694037,
       population_type: 1,
       primary_key: "13453",
       short_name: "Красногорск, г.о.",
       snowfall_started: 1576393014,
       snowfall_status: "Уборка снегопада",
       tasks_completed: 384,
       tasks_failed: 545,
       tasks_in_work: 94,
       tasks_total: 1023,
       total_dispatchers: 2,
       total_users: 73,
       total_workers: 71,
       total_yards: 342,
       updated_at: 1576429477
     }
   ],
   total_dispatchers: 2,
   total_users: 73,
   total_workers: 71,
   total_yards: 342
 }

    {:ok, data} 
  end

  def get_report_eager(report_key ) do
    case report_key do
      :snow -> get_snow_report()
      :total-> get_total_report()
      :planned -> get_planned_report()
    end
  end
    
  def get_report_eager(report_key, _try_number, _total_tries) do
    get_report_eager(report_key)
  end
end
