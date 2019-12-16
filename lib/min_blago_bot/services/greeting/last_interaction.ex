defmodule MinBlagoBot.Services.Greeting.LastInteraction do

  use GenServer

  @table :last_interaction

  def init(state) do
    :ets.new(@table, [:set, :private, :named_table])
    
    # вызываем разогрев кеша после инита
    {:ok, state}
  end

  ### ================
  # Interface
  ### ================

  def get_last(user_id),   do: GenServer.call(__MODULE__, {:get_last, user_id})
  def update(user_id),     do: GenServer.cast(__MODULE__, {:update, user_id})

  ### ================
  # Genserver
  ### ================

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def handle_call({:get_last, user_id}, _from, state) do
    result = 
     :ets.lookup(@table, user_id) 
     |> value_from_ets_lookup!()

    {:reply, result, state}
  end

  def handle_cast({:update, user_id}, state) do
    :ets.insert(@table, {user_id, Timex.local()})
    
    {:noreply, state}
  end

  defp value_from_ets_lookup!([]),                    do: nil 
  defp value_from_ets_lookup!([{_key, value}]),       do: value
  defp value_from_ets_lookup!(arg) when is_list(arg), do: raise ArgumentError, "more than one results returned #{inspect(arg)}" 
  defp value_from_ets_lookup!(arg),                   do: raise ArgumentError, "invalid argument #{inspect(arg)}" 
end
