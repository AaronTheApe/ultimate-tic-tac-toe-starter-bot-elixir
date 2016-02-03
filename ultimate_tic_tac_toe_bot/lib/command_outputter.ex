defmodule CommandOutputter do
   def start() do
       {:ok, logic} = Task.start_link(fn->send_input() end)
       logic
   end

   def send_input() do
      receive do
         {:message, message} ->
               IO.puts message
         {:error, msg} -> nil
         _ -> nil
      end
      send_input()
   end


end
