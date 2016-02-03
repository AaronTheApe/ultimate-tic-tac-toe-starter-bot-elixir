defmodule RandomStrategy do
  def start(outputter) do
    {:ok, logic} = Task.start_link(fn->recv(outputter) end)
    logic
  end

  def array_pos_to_grid_pos(a_pos) do
    x = rem a_pos, 9
    y = div a_pos, 9
    {x, y}
  end

  def grid_pos_to_array_pos({x, y}) do
    y * 9 + x
  end

  def macro_pos_to_grid_range(x) do
    case x do
      0 ->
        {{0, 2}, {0, 2}}
      1 ->
        {{3, 5}, {0, 2}}
      2 ->
        {{6, 8}, {0, 2}}
      3 ->
        {{0, 2}, {3, 5}}
      4 ->
        {{3, 5}, {3, 5}}
      5 ->
        {{6, 8}, {3, 5}}
      6 ->
        {{0, 2}, {6, 8}}
      7 ->
        {{3, 5}, {6, 8}}
      8 ->
        {{6, 8}, {6, 8}}
    end
  end

  def grid_range_to_array_range({{x_min, x_max}, {y_min, y_max}}) do
    Enum.flat_map(x_min..x_max, fn(x) ->
        Enum.map(y_min..y_max, fn(y) ->
            grid_pos_to_array_pos({x, y})
          end)
      end)
  end

  def forced_squares(state) do
    state.game_macroboard
    |> Enum.with_index
    |> Enum.filter(fn(x) ->  elem(x, 0) == -1 end)
    |> Enum.map(fn(x) ->
        macro_pos_to_grid_range(elem(x,1))
      end)
    |> Enum.flat_map(fn(x) ->
        grid_range_to_array_range(x)
      end)
  end

  def empty_squares(state) do
    state.game_field
    |> Enum.with_index
    |> Enum.filter(fn(x) -> elem(x, 0) == 0 end)
    |> Enum.map(fn(x) -> elem(x, 1) end)
  end

  def available_squares(state) do
    f_squares = forced_squares(state)
    e_squares = empty_squares(state)
    if f_squares == [] do
      e_squares
    else
      Enum.filter(e_squares, fn(a) -> Enum.member?(f_squares, a) end)
    end
  end

  def pick_random(list) do
    if length(list) == 1 do
      List.first(list)
    else
      Enum.at(list, :random.uniform(length(list)) - 1)
    end
  end

  def move_randomly(state) do
    :random.seed(:os.timestamp)
    a_squares = available_squares(state)
    r_square = pick_random(a_squares)
    move = array_pos_to_grid_pos(r_square)
    x = elem(move, 0)
    y = elem(move, 1)
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
