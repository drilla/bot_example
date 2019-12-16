defmodule LastInteractionTest do
  use ExUnit.Case

  alias MinBlagoBot.Services.Greeting.LastInteraction
  
  test "empty table not found result" do
   any_number = 1
   assert LastInteraction.get_last(any_number) == nil
  end 
  
  test "not found result and updated" do
   any_number = 2
   LastInteraction.update(any_number)
   Process.sleep(100)

   assert LastInteraction.get_last(any_number) != nil
  end

  test "found result and updated" do
   any_number = 3 
   LastInteraction.update(any_number)
   Process.sleep(100)

   last_call = LastInteraction.get_last(any_number)
   assert last_call != nil
  
   LastInteraction.update(any_number)
   last_last_call = LastInteraction.get_last(any_number) 
   assert last_last_call > last_call 
  end
end