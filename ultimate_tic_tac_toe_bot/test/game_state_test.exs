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
     assert %{:timebank => 0,
              :time_per_move => 0,
              :player_names => [],
              :bot_name => "",
              :bot_id => 0,
              :game_round => 0,
              :game_move => 0,
              :game_field => [],
              :game_macroboard => []
             } == GameState.initial()
   end

   GameStateTestMacro.test_state "should set timebank", :timebank, :set_timebank, 1000, 100
   GameStateTestMacro.test_state "should set time per move", :time_per_move, :set_time_per_move, 500, 50
   GameStateTestMacro.test_state "should set player names", :player_names, :set_player_names, ["bot5", "bot6"], ["bot1", "bot2"]
   GameStateTestMacro.test_state "should set bot name", :bot_name, :set_bot_name,"bot1", "bot2"
   GameStateTestMacro.test_state "should set bot id", :bot_id, :set_bot_id, 1, 2
   GameStateTestMacro.test_state "should set game round", :game_round, :set_game_round, 1, 2
   GameStateTestMacro.test_state "should set game move", :game_move, :set_game_move, 1, 2
   GameStateTestMacro.test_state "should set game field", :game_field, :set_game_field, [1, 2, 3, 4], [3, 2, 4, 5]
   GameStateTestMacro.test_state "should set game macroboard", :game_macroboard, :set_game_macroboard, [1, 2, 3, 4], [3, 2, 4, 5]
end
