defmodule CommandParserMacro do
   defmacro test_communication(desc, msg, atom, return_msg) do
      quote do
         test unquote(desc) do
             assert_command_parser_communication(unquote(msg), unquote(atom), unquote(return_msg))
         end
      end
   end
end

defmodule CommandParserTest do
    use ExUnit.Case
    require CommandParserMacro

    def assert_command_parser_communication(message, atom, expected) do
        command_parser = CommandParser.start(self())
        CommandParser.send_message(command_parser, message)
        receive do
           {a, x} ->
                assert x == expected
                assert a == atom
           _ ->   assert false
        end

    end

    CommandParserMacro.test_communication "sending invalid message sends out error code", "INVALID MESSAGE", :error, "Invalid Message Received"
    CommandParserMacro.test_communication "Returns starting region list given a list",
                                          "pick_starting_region 10000 2 6 10 19 20 26 32 33 38 45 55 62",
                                          :starting_region_choice,
                                           ["2", "6", "10", "19", "20", "26","32", "33", "38", "45", "55", "62"]
    CommandParserMacro.test_communication "Returns armies to place", "go place_armies 10000", :place_armies, ""
    CommandParserMacro.test_communication "Returns attack/transfer", "go attack/transfer 10000", :attack_transfer, ""
    CommandParserMacro.test_communication "updates timebank", "settings timebank 1000", :initial_timebank, 1000
    CommandParserMacro.test_communication "updates time_per_move", "settings time_per_move 500", :time_per_move, 500
    CommandParserMacro.test_communication "updates max_round", "settings max_rounds 100", :max_rounds, 100
    CommandParserMacro.test_communication "updates bot_name", "settings your_bot player1", :bot_name, "player1"
    CommandParserMacro.test_communication "updates opponent bot_name", "settings opponent_bot player2", :opponent_bot_name, "player2"
    CommandParserMacro.test_communication "updates starting armies", "settings starting_armies 3", :starting_armies, 3
    CommandParserMacro.test_communication "updates starting regions", "settings starting_regions 1 2 4 7", :starting_regions, ["1", "2", "4" ,"7"]
    CommandParserMacro.test_communication "updates starting pick amount", "settings starting_pick_amount 1", :starting_pick_amount, 1
    CommandParserMacro.test_communication "indicate super regions", "setup_map super_regions 1 2 3 4", :super_regions, [["1", 2], ["3", 4]]
    CommandParserMacro.test_communication "indicate regions", "setup_map regions 1 3 2 3 3 1 4 1", :regions, [{"1", ["3","4"]}, {"3", ["1", "2"]}]
    CommandParserMacro.test_communication "indicate neighbors", "setup_map neighbors 1 2,3 2 1 3 1", :neighbors, %{"1"=> ["2","3"], "2"=> ["1"], "3"=>["1"]}
    CommandParserMacro.test_communication "indicate wastelands", "setup_map wastelands 3 4", :wastelands, ["3", "4"]
    CommandParserMacro.test_communication "indicate opponent_starting_moves", "setup_map opponent_starting_regions 5 2", :opponent_starting_regions, ["5", "2"]
    CommandParserMacro.test_communication "update map", "update_map 1 player1 1 2 player2 4", :update_map, [{"1", "player1", 1}, {"2", "player2", 4}]
    CommandParserMacro.test_communication "get last opponent moves", "opponent_moves player1 place_armies 1 1 player1 attack/transfer 3 1 4", :last_opponent_moves, [{"player1", "place_armies", "1", 1}, {"player1", "attack/transfer", "3", "1", 4}]

    test "can send :eof without throwing exception" do
       command_parser = CommandParser.start(self())
       CommandParser.send_message(command_parser, :eof)
    end
end
