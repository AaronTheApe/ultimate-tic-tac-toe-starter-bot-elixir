defmodule GameStateTestMacro do


  defmacro test_state desc, setting, func, first_val, first_expected, second_val, second_expected do

    quote do
       test unquote(desc) do
          assert %{GameState.initial | unquote(setting) => unquote(first_expected)} ==  apply(GameState, unquote(func), [GameState.initial(), unquote(first_val)])
          assert %{GameState.initial | unquote(setting) => unquote(second_expected)} == apply(GameState, unquote(func), [apply(GameState, unquote(func), [GameState.initial(), unquote(first_val)]), unquote(second_val)])

       end
  end
    end

  defmacro test_state desc, setting, func, first_val, second_val do
     quote do
        test unquote(desc) do
           assert %{GameState.initial | unquote(setting) => unquote(first_val)} ==  apply(GameState, unquote(func), [GameState.initial(), unquote(first_val)])
           assert %{GameState.initial | unquote(setting) => unquote(second_val)} == apply(GameState, unquote(func), [apply(GameState, unquote(func), [GameState.initial(), unquote(first_val)]), unquote(second_val)])

        end
     end
  end


end

defmodule GameStateTest do
   use ExUnit.Case
   require GameStateTestMacro
   test "should have correct initial state" do
       assert %{:timebank => 0, :time_per_move => 0,
                :max_rounds => 0, :bot_name =>"",
                :opponent_bot_name => "",
                :starting_armies => 0,
                :starting_regions => [],
                :starting_pick_amount => 0,
                :map => %{},
                :neighbors => %{},
                :ownership=>%{},
                :opponent_starting_regions=>[],
                :last_opponent_moves=>[]} == GameState.initial()
   end

   GameStateTestMacro.test_state "should set timebank", :timebank, :set_timebank, 1000, 100
   GameStateTestMacro.test_state "should set time per move", :time_per_move, :set_time_per_move, 500, 50
   GameStateTestMacro.test_state "should set max rounds", :max_rounds, :set_max_rounds, 100, 200
   GameStateTestMacro.test_state "should set bot name", :bot_name, :set_bot_name,"bot1", "bot2"
   GameStateTestMacro.test_state "should set opponent name", :opponent_bot_name, :set_opponent_bot_name,"bot2", "bot1"
   GameStateTestMacro.test_state "should set starting armies", :starting_armies, :set_starting_armies,3, 5
   GameStateTestMacro.test_state "should set starting regions", :starting_regions, :set_starting_regions, [4], [4,12]
   GameStateTestMacro.test_state "should set starting pick amount", :starting_pick_amount, :set_starting_pick_amount, 1, 5


   def make_super_region state, super_region, bonus_armies, regions \\ [] do
      Map.put_new state, super_region, %{:bonus_armies => bonus_armies, :regions => regions}
   end

   GameStateTestMacro.test_state "should set superregions", :map, :set_super_regions, [["1",2], ["3", 4]], %{} |> make_super_region("1", 2) |> make_super_region("3", 4), [["1",2],["3",4],["5",6]], %{} |> make_super_region("1", 2) |> make_super_region("3", 4) |>make_super_region("5", 6)


   test "setting regions creates ownership and regions" do
     state = GameState.initial
          |> GameState.set_super_regions([["1", 2], ["3", 4]])

     expected_state = %{state | :map => %{} |> make_super_region("1", 2, ["3","4"])
                                            |> make_super_region("3", 4, ["1","2"]),
                               :ownership => %{"1" =>{"neutral", 2}, "2" =>{"neutral", 2}, "3" =>{"neutral", 2}, "4" =>{"neutral", 2}}}
     assert expected_state == state |> GameState.set_regions [{"1", ["3", "4"]}, {"3", ["1","2"]}]
   end

   test "can set wastelands" do
     state = GameState.initial
          |> GameState.set_super_regions([["1", 2], ["3", 4]])
          |> GameState.set_regions [{"1", ["3", "4"]}, {"3", ["1","2"]}]

     expected_state = %{state | :map => %{} |> make_super_region("1", 2, ["3","4"])
                                            |> make_super_region("3", 4, ["1","2"]),
                               :ownership => %{"1" =>{"fog", 2}, "2" =>{"neutral", 6}, "3" =>{"neutral", 6}, "4" =>{"fog", 2}}}
     assert expected_state == state |> GameState.set_wastelands ["2", "3"]
   end

   test "can update map" do
    state = GameState.initial
         |> GameState.set_super_regions([["1", 2], ["3", 4]])
         |> GameState.set_regions [{"1", ["3", "4"]}, {"3", ["1","2"]}]

    expected_state = %{state | :map => %{} |> make_super_region("1", 2, ["3","4"])
                                           |> make_super_region("3", 4, ["1","2"]),
                              :ownership => %{"1" =>{"fog", 2}, "2" =>{"player1", 4}, "3" =>{"fog", 2}, "4" =>{"fog", 2}}}
    assert expected_state == state |> GameState.update_map([{"2", "player1", 4}])

    new_expected_state = %{state | :ownership => %{"1" =>{"player1", 5}, "2" =>{"player1", 4}, "3" =>{"player2", 5}, "4" =>{"fog", 2}}}
    assert new_expected_state == state |> GameState.update_map([{"2", "player1", 4}]) |> GameState.update_map([{"1", "player1", 5},{"2", "player1", 4}, {"3", "player2", 5}])
   end

   GameStateTestMacro.test_state "should set opponent starting_regions", :opponent_starting_regions, :set_opponent_starting_regions, ["1","2","3"], ["1", "2","3","4"]
   GameStateTestMacro.test_state "should set last_opponent_moves", :last_opponent_moves, :set_last_opponent_moves, [{"1", "2", 3}], [{"player2", "attack/transfer", "1", "2", 3}, {"player2", "place_armies", "3", "2", 2}]


   test "can get armies at position" do
      state = GameState.initial
           |> GameState.set_super_regions([["1", 2], ["3", 4]])
           |> GameState.set_regions [{"1", ["3", "4"]}, {"3", ["1","2"]}]
      new_state = GameState.update_map(state, [{"2", "player1", 4}])
      assert 2 == GameState.get_armies(new_state, "1")
      assert 4 == GameState.get_armies(new_state, "2")
      assert 2 == GameState.get_armies(new_state, "3")
      assert 2 == GameState.get_armies(new_state, "4")
   end

   test "updating neighbors updates both ways" do
      state = GameState.initial
           |> GameState.set_super_regions([["1", 2], ["3", 4]])
           |> GameState.set_regions [{"1", ["3", "4"]}, {"3", ["1","2"]}]
      assert %{state | :neighbors => %{"1" => ["2"], "2" => ["1"]}} == GameState.set_neighbors(state, %{"1"=>["2"]})
   end

end
