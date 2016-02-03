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

  GameLogicMacro.create_handle_func "time_per_move"
  GameLogicMacro.create_handle_func "bot_name"
  GameLogicMacro.create_handle_func "opponent_bot_name"
  GameLogicMacro.create_handle_func "starting_armies"
  GameLogicMacro.create_handle_func "starting_regions"
  GameLogicMacro.create_handle_func "starting_pick_amount"
  GameLogicMacro.create_handle_func "super_regions"
  GameLogicMacro.create_handle_func "regions"
  GameLogicMacro.create_handle_func "neighbors"
  GameLogicMacro.create_handle_func "wastelands"
  GameLogicMacro.create_handle_func "opponent_starting_regions"
  GameLogicMacro.create_handle_func "last_opponent_moves"
  GameLogicMacro.create_passalong_func :place_armies
  GameLogicMacro.create_passalong_func :attack_transfer

  defp handle(strategy, state, {:starting_region_choice, list}) do
      send(strategy, {:pick_starting, {list,state}})
      state
  end

  defp handle(strategy, state, {:update_map, regions}), do: GameState.update_map(state, regions)

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
