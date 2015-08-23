defmodule SimpleGameLogicTest do
   use ExUnit.Case

   def assert_send_logic(message, expected, atom) do
      logic = SimpleGameLogic.start self()
      send logic, message
      receive do
         {a, msg} ->
               assert msg == expected
               assert a == atom
         _ -> assert false, "Did not receive a well-formed message"
      end
   end

   test "should error out on invalid message" do
       assert_send_logic({:invalid, ""}, "Invalid Message Received", :error)
   end

   test "should pick first starting region" do
      assert_send_logic({:starting_region_choice, ["5", "7", "3", "1", "200", "12", "4"]}, "5", :message)
   end

   test "should pick a different first starting region" do
       assert_send_logic({:starting_region_choice, ["7", "3", "1", "200", "12", "4"]}, "7", :message)
   end
end
