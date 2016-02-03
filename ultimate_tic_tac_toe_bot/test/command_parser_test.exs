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
    CommandParserMacro.test_communication "updates timebank", "settings timebank 1000", :initial_timebank, 1000
    CommandParserMacro.test_communication "updates time_per_move", "settings time_per_move 500", :time_per_move, 500
    CommandParserMacro.test_communication "updates player_names", "settings player_names player1,player2", :player_names, ["player1","player2"]
    CommandParserMacro.test_communication "updates bot_name", "settings your_bot player1", :bot_name, "player1"
    CommandParserMacro.test_communication "updates botid", "settings your_botid 1", :botid, 1

    CommandParserMacro.test_communication "updates game_round", "update game round 1", :game_round, 1
    CommandParserMacro.test_communication "updates game_move", "update game move 1", :game_move, 1
    CommandParserMacro.test_communication "updates game_field", "update game field 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0", :game_field, [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    CommandParserMacro.test_communication "updates game_macroboard", "update game macroboard -1,-1,-1,-1,-1,-1,-1,-1,-1", :game_macroboard, [-1,-1,-1,-1,-1,-1,-1,-1,-1]
    CommandParserMacro.test_communication "requests a move", "action move 10000", :action_move, 10000

    test "can send :eof without throwing exception" do
       command_parser = CommandParser.start(self())
       CommandParser.send_message(command_parser, :eof)
    end
end
