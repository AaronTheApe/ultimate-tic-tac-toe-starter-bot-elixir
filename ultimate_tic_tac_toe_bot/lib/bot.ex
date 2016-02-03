defmodule Bot do
   def main(_) do

      outputter = CommandOutputter.start()
      strategy = RandomStrategy.start(outputter)
      logic = SimpleGameLogic.start(strategy)
      command_parser = CommandParser.start(logic)
      run_input_loop( command_parser)
   end

   def run_input_loop(parser) do
      command = IO.gets ""
      CommandParser.send_message(parser, command)

      run_input_loop( parser)
   end

end
