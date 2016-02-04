defmodule Util do
  def field_to_grid_pos(field) do
    x = rem field, 9
    y = div field, 9
    {x, y}
  end

  def grid_pos_to_field({x, y}) do
    y * 9 + x
  end

  def macro_field_to_grid_range(macro_field) do
    case macro_field do
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

  def grid_range_to_field_range({{x_min, x_max}, {y_min, y_max}}) do
    Enum.flat_map(x_min..x_max, fn(x) ->
        Enum.map(y_min..y_max, fn(y) ->
            grid_pos_to_field({x, y})
          end)
      end)
  end

  def forced_fields(state) do
    state.game_macroboard
    |> Enum.with_index
    |> Enum.filter(fn(x) ->  elem(x, 0) == -1 end)
    |> Enum.map(fn(x) ->
        macro_field_to_grid_range(elem(x,1))
      end)
    |> Enum.flat_map(fn(x) ->
        grid_range_to_field_range(x)
      end)
  end

  def empty_fields(state) do
    fields_containing(state, 0)
  end

  def available_fields(state) do
    f = forced_fields(state)
    e = empty_fields(state)
    if f == [] do
      e
    else
      Enum.filter(e, fn(x) -> Enum.member?(f, x) end)
    end
  end

  def fields_containing(state, symbol) do
    state.game_field
    |> Enum.with_index
    |> Enum.filter(fn(x) -> elem(x, 0) == symbol end)
    |> Enum.map(fn(x) -> elem(x, 1) end)
  end

  def your_fields(state) do
    fields_containing(state, state.botid)
  end

  def their_fields(state) do
    botid = case state.botid do
              1 -> 2
              2 -> 1
            end
    fields_containing(state, botid)
  end

  def pick_random(list) do
    if length(list) == 1 do
      List.first(list)
    else
      Enum.at(list, :random.uniform(length(list)) - 1)
    end
  end

  def base_micro_lines do
    [
      [{0,0},{0,1},{0,2}],
      [{1,0},{1,1},{1,2}],
      [{2,0},{2,1},{2,2}],
      [{0,0},{1,0},{2,0}],
      [{0,1},{1,1},{2,1}],
      [{0,2},{1,2},{2,2}],
      [{0,0},{1,1},{2,2}],
      [{0,2},{1,1},{2,0}]
    ]
  end

  def macro_square_offset(macro_square) do
    case macro_square do
      0 ->
        {0,0}
      1 ->
        {3,0}
      2 ->
        {6,0}
      3 ->
        {0,3}
      4 ->
        {3,3}
      5 ->
        {6,3}
      6 ->
        {0,6}
      7 ->
        {3,6}
      8 ->
        {6,6}
    end
  end

  def micro_lines(macro_square) do
    offset = macro_square_offset(macro_square)
    base_micro_lines
    |> Enum.map(fn(base_line) ->
      base_line
      |> Enum.map(fn(square) ->
        {elem(square, 0) + elem(offset, 0),
         elem(square, 1) + elem(offset, 1)}
      end)
    end)
  end

  def micro_lines do
    0..8
    |> Enum.flat_map(fn(macro_square) ->
      micro_lines(macro_square)
    end)
  end

  def available_micro_lines(state) do
    micro_lines
    |> Enum.filter(fn(micro_line) ->
      Enum.member?
    end)
  end

  def macro_lines do
    [[0,1,2],
     [3,4,5],
     [6,7,8],
     [0,3,6],
     [1,4,7],
     [2,5,8],
     [0,4,8],
     [2,4,6]]
  end

  def count_symbol(game_field, micro_line, symbol) do
    Enum.count(micro_line, fn(grid_pos) ->
      symbol_at_grid_pos(game_field, grid_pos) == symbol
    end)
  end

  def symbol_at_grid_pos(game_field, grid_pos) do
    Enum.at(game_field, grid_pos_to_field(grid_pos))
  end

  def one_short(game_field, micro_line, symbol) do
    num_empty = count_symbol(game_field, micro_line, 0)
    num_symbol = count_symbol(game_field, micro_line, symbol)
    num_empty == 1 and num_symbol == 2
  end

  def completer(game_field, micro_line) do
    micro_line
    |> Enum.filter(fn(grid_pos) -> symbol_at_grid_pos(game_field, grid_pos) == 0 end)
    |> List.first
  end

  def completer_grid_pos(game_field, symbol) do
    micro_lines
    |> Enum.filter_map(
      fn(micro_line) -> one_short(game_field, micro_line, symbol) end,
      fn(micro_line) -> completer(game_field, micro_line) end)
  end
end
