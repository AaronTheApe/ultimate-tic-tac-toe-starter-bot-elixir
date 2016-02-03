defmodule CustomLogger do

   def start do
      {:ok, logger} = Task.start_link(fn->log() end)
      send logger, {:init, ""}
      logger
  end

  def write(logger, msg) do
     send logger, {:write, msg}
  end

  def log do
    receive do
       {:init, _} ->
           {:ok, file} = File.open "log.txt", [:write]
           File.close  file
           log()
       {:write, msg} ->
           {:ok, file} = File.open "log.txt", [:append]
           IO.write file, msg
           IO.write file, "\n"
           IO.puts :stderr, msg
           File.close file
           log()
    end


  end
end
