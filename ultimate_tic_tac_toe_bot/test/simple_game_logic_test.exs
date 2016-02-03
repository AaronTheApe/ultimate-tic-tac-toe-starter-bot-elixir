defmodule LogicTestMacro do
   defmacro test_setting(desc, setting, func, value) do
     quote do
        test unquote(desc) do
           assert_send_settings {unquote(setting), unquote(value)}, apply( GameState, unquote(func), [GameState.initial, unquote(value)])
        end
     end
   end
end

defmodule SimpleGameLogicTest do
   use ExUnit.Case
   require LogicTestMacro
   def assert_send_logic(logic, message, expected, atom) do
      send logic, message
      receive do
         {a, msg} ->
               assert msg == expected
               assert a == atom
         _ -> assert false, "Did not receive a well-formed message"
      end
      logic
   end

   def assert_send_logic(message, expected, atom) do
      logic = SimpleGameLogic.start self()
      assert_send_logic(logic, message, expected,atom)
   end

   test "should error out on invalid message" do
       assert_send_logic({:invalid, ""}, "Invalid Message Received", :error)
   end

   test "can get initial state" do
       assert_send_logic({:state, self()}, GameState.initial, :state)
   end

   def assert_send_settings(msg, expected_state) do
       logic = SimpleGameLogic.start self()
       send logic, msg
       assert_send_logic(logic, {:state, self()},  expected_state, :state)
  end

  LogicTestMacro.test_setting "should set timebank", :initial_timebank, :set_timebank, 100
  LogicTestMacro.test_setting "should set time per move", :time_per_move, :set_time_per_move, 50
  LogicTestMacro.test_setting "should set bot name", :bot_name, :set_bot_name, "player1"
end
