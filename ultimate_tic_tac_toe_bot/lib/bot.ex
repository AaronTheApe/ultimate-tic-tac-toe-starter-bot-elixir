defmodule Bot do
   def main(_) do
      CommandOutputter.start
      |> CompleterStrategy.start
      |> SimpleGameLogic.start
      |> CommandParser.start
      |> run_input_loop
   end

   def run_input_loop(parser) do
      command = IO.gets ""
      CommandParser.send_message(parser, command)

      run_input_loop( parser)
   end

end
