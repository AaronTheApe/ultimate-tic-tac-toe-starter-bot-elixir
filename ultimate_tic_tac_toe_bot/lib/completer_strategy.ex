defmodule CompleterStrategy do
  import Util

  def start(outputter) do
    {:ok, logic} = Task.start_link(fn->recv(outputter) end)
    logic
  end

  def complete_if_possible(state) do
    :random.seed(:os.timestamp)
    available_grid_pos = Enum.map(
      available_fields(state),
      fn(field) -> field_to_grid_pos(field) end)
    completers = completer_grid_pos(state.game_field, state.botid)
    available_completers = Enum.filter(
      completers,
      fn(completer) -> Enum.member?(available_grid_pos, completer) end)
    move = if available_completers == [] do
      pick_random(available_grid_pos)
    else
      pick_random(available_completers)
    end
    x = elem(move, 0)
    y = elem(move, 1)
    "place_move #{x} #{y}"
  end

  def recv outputter do
    receive do
      {:action_move, state} ->
        msg = complete_if_possible(state)
        send outputter, {:message, msg}
      _ ->
        send outputter, {:error, "Invalid Message Received"}
    end
    recv(outputter)
  end
end
