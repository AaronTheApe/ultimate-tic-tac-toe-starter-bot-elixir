defmodule GameStateMacro do
  defmacro create_updater(setting) do
    quote do
      def unquote(:"set_#{setting}")(state, val) do
        %{state | String.to_atom(unquote(setting)) => val}
      end
    end
  end
end

defmodule GameState do
  require GameStateMacro
  def initial() do
    %{:timebank => 0,
      :time_per_move => 0,
      :player_names => [],
      :bot_name => "",
      :botid => 0,
      :game_round => 0,
      :game_move => 0,
      :game_field => [],
      :game_macroboard => []
     }
  end

  GameStateMacro.create_updater "timebank"
  GameStateMacro.create_updater "time_per_move"
  GameStateMacro.create_updater "player_names"
  GameStateMacro.create_updater "bot_name"
  GameStateMacro.create_updater "botid"
  GameStateMacro.create_updater "game_round"
  GameStateMacro.create_updater "game_move"
  GameStateMacro.create_updater "game_field"
  GameStateMacro.create_updater "game_macroboard"
end
