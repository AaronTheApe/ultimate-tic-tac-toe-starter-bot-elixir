defmodule RandomStrategy do
  def start(outputter) do
    {:ok, logic} = Task.start_link(fn->recv(outputter) end)
    logic
  end

  def move_randomly(state) do
    :random.seed(:os.timestamp)
    x = :random.uniform(9) - 1
    y = :random.uniform(9) - 1
    "place_move #{x} #{y}"
  end

  def recv outputter do
    receive do
      {:action_move, state} ->
        msg = move_randomly(state)
        send outputter, {:message, msg}
      _ ->
        send outputter, {:error, "Invalid Message Received"}
    end
    recv(outputter)
  end
end
