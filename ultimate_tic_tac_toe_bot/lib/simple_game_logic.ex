defmodule GameLogicMacro do
   defmacro create_handle_func(param_name) do
     quote do
        defp handle(_strategy, state, {unquote(:"#{param_name}"), x}) do
           apply( GameState, unquote(:"set_#{param_name}"), [state, x])
        end
     end
   end

   defmacro create_passalong_func(atom) do
      quote do
        defp handle(strategy, state, {unquote(atom), _})  do
           send(strategy, {unquote(atom), state})
           state
        end
      end
   end
end

defmodule SimpleGameLogic do
  require GameLogicMacro
  def start(strategy) do
      {:ok, logic} = Task.start_link(fn->recv(strategy, GameState.initial) end)
      logic
  end

  defp handle(_, state, {:state, sender}) do
     send(sender, {:state, state})
     state
  end

  defp handle(strategy, state, {:initial_timebank, time}) do
    recv(strategy, GameState.set_timebank(state, time))
    state
  end

  GameLogicMacro.create_handle_func "timebank"
  GameLogicMacro.create_handle_func "time_per_move"
  GameLogicMacro.create_handle_func "player_names"
  GameLogicMacro.create_handle_func "bot_name"
  GameLogicMacro.create_handle_func "botid"
  GameLogicMacro.create_handle_func "game_round"
  GameLogicMacro.create_handle_func "game_move"
  GameLogicMacro.create_handle_func "game_field"
  GameLogicMacro.create_handle_func "game_macroboard"

  GameLogicMacro.create_passalong_func :action_move

  defp handle(strategy, state, _) do
    send( strategy, {:error, "Invalid Message Received"})
    state
  end

  def recv(strategy, state) do
      receive do
         m -> recv(strategy, handle(strategy, state, m))
      end
      recv(strategy,  state)
  end
end
