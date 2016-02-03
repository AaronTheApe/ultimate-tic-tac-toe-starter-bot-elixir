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

   test "should send out state on starting_choice" do
      assert_send_logic({:starting_region_choice, ["1", "2", "3"]}, {["1", "2", "3"], GameState.initial}, :pick_starting)
   end

   test "should error out on invalid message" do
       assert_send_logic({:invalid, ""}, "Invalid Message Received", :error)
   end

   test "placing armies should send state" do
       assert_send_logic({:place_armies, ""},  GameState.initial, :place_armies)
   end

   test "attacking should send state" do
       assert_send_logic({:attack_transfer, ""},  GameState.initial, :attack_transfer)
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
  LogicTestMacro.test_setting "should set max rounds", :max_rounds, :set_max_rounds, 50
  LogicTestMacro.test_setting "should set bot name", :bot_name, :set_bot_name, "player1"
  LogicTestMacro.test_setting "should set opponent bot name", :opponent_bot_name, :set_opponent_bot_name, "player2"
  LogicTestMacro.test_setting "should set starting_armies", :starting_armies, :set_starting_armies, 5
  LogicTestMacro.test_setting "should set starting regions", :starting_regions, :set_starting_regions, [3, 5, 7,  11, 12]
  LogicTestMacro.test_setting "should set starting pick amount", :starting_pick_amount, :set_starting_pick_amount, 1
  LogicTestMacro.test_setting "should set super regions", :super_regions, :set_super_regions, [["1", 2], ["3", 4]]

  test "should set regions " do
     logic = SimpleGameLogic.start self()
     send logic, {:super_regions, [["1", 2], ["3", 4]]}
     send logic, {:regions, [{"1", ["3", "4"]}, {"3", ["1","2"]}]}
     expected_state = GameState.initial |> GameState.set_super_regions([["1", 2], ["3", 4]]) |> GameState.set_regions [{"1", ["3", "4"]}, {"3", ["1","2"]}]
     assert_send_logic logic, {:state, self()},  expected_state, :state
  end

  LogicTestMacro.test_setting "should set neighbors", :neighbors, :set_neighbors, %{"1" => ["2", "3"], "2" => ["1"], "3"=>["1"]}


  test "should set wastelands after setting regions" do
        logic = SimpleGameLogic.start self()
        send logic, {:super_regions, [["1", 2], ["3", 4]]}
        send logic, {:regions, [{"1", ["3", "4"]}, {"3", ["1","2"]}]}
        send logic, {:wastelands, ["2", "3"]}
        state2 = GameState.initial
              |> GameState.set_super_regions([["1", 2], ["3", 4]])
              |> GameState.set_regions [{"1", ["3", "4"]}, {"3", ["1","2"]}]
        expected_state = GameState.set_wastelands state2, ["2", "3"]
        assert_send_logic logic, {:state, self()},  expected_state, :state
  end

  LogicTestMacro.test_setting "should set opponent_starting_regions", :opponent_starting_regions, :set_opponent_starting_regions, ["1", "2"]
  LogicTestMacro.test_setting "should set updated map", :update_map, :update_map, [{"1", "player1", 17}]
  LogicTestMacro.test_setting "should set last opponent moves", :last_opponent_moves, :set_last_opponent_moves, [{"player1", "place_armies", "1", "1", 2}, {"player1", "attack/transfer", "3", "2", 5}]


end
