defmodule DumbStrategyTest do
   use ExUnit.Case

   def assert_send(message, expected, atom) do
      strategy = DumbStrategy.start self()
      send strategy, message
      receive do
         {a, msg} ->
               assert msg == expected
               assert a == atom
         _ -> assert false, "Did not receive a well-formed message"
      end
   end

   test "bad message return invalid" do
       assert_send({"INVALID", {}}, "Invalid Message Received", :error)
   end

   test "should pick first starting region" do
      assert_send({:pick_starting, {["5", "7", "3", "1", "200", "12", "4"], {} } }, "5", :message)
   end

   test "should pick a different first starting region" do
       assert_send({:pick_starting, {["7", "3", "1", "200", "12", "4"], {}}}, "7", :message)
   end

   test "no moves on place_armies" do
       assert_send({:place_armies, {}}, "No Moves", :message)
   end

   test "no moves on attack_transfer" do
       assert_send({:attack_transfer, {}}, "No Moves", :message)
   end

end
