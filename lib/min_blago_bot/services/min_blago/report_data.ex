defmodule MinBlagoBot.Services.MinBlago.ReportData do
  @moduledoc """
  Данные, необходимые чтобы построить отчет по дворам / снегопадам из минблаго
  """
  
  @type t() :: %__MODULE__{
    date_time:            DateTime.t(),
    total_yards:          integer(),
    total_yards:          integer(),
    total_users:          integer(),
    total_workers:        integer(),
    total_dispatchers:    integer(),
    active_users:         integer(), 
    active_workers:       integer(), 
    active_dispatchers:   integer(), 
    inactive_users:       integer(), 
    inactive_workers:     integer(), 
    inactive_dispatchers: integer(),
    tasks_total:          integer(),
    tasks_completed:      integer(),
    tasks_in_work:        integer(),
    tasks_failed:         integer(),
    top_omsu_population_200:     list(),
    top_omsu_population_100_200: list(),
    top_omsu_population_100:     list(),
    snowfall_started:  list() | []   # актуально только для отчета по снегу. не создавать же новую структуру?
  }
  
  defstruct [
    :total_yards,     
    :total_users,
    :total_workers,
    :total_dispatchers,
    :active_users,
    :active_workers,
    :active_dispatchers,
    :inactive_users,
    :inactive_workers,
    :inactive_dispatchers,
    :tasks_total,
    :tasks_completed,
    :tasks_in_work,
    :tasks_failed,
    :top_omsu_population_200,
    :top_omsu_population_100_200,
    :top_omsu_population_100,
    date_time: nil,
    snowfall_started: [], # снег
  ]
end