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
    CommandParserMacro.test_communication "updates bot_name", "settings your_bot player1", :bot_name, "player1"
    CommandParserMacro.test_communication "updates opponent bot_name", "settings opponent_bot player2", :opponent_bot_name, "player2"

    test "can send :eof without throwing exception" do
       command_parser = CommandParser.start(self())
       CommandParser.send_message(command_parser, :eof)
    end
end
