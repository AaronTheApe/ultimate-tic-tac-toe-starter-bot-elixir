defmodule RandomStrategy do

    def start(outputter) do
        {:ok, logic} = Task.start_link(fn->recv(outputter) end)
        logic
    end

    defp pick_random list do
      if length(list) == 1 do
          List.first(list)
      else
         Enum.at(list, :random.uniform(length(list)) - 1)
      end
    end

    defp get_own_areas(state) do
       Enum.map (Enum.filter state.ownership, (fn {_, {player_name, _}} -> player_name == state.bot_name end)), &(elem(&1, 0))
    end

    defp place_armies_randomly_at_one_location(state) do
        own_areas = get_own_areas state
        state.bot_name <> " place_armies " <> pick_random(own_areas) <> " " <> Integer.to_string state.starting_armies
    end

    defp attack_randomly(state) do

        own_areas = get_own_areas state
        big_areas = Enum.filter own_areas, &(GameState.get_armies(state, &1) > 1)
        starting_region = pick_random(big_areas)
        neighbors = state.neighbors[starting_region]
        num_armies = Integer.to_string(GameState.get_armies(state, starting_region) - 1)

        state.bot_name <> " attack/transfer " <> starting_region <> " " <> pick_random(neighbors) <> " " <> num_armies

    end

    def recv outputter do
        :random.seed(:os.timestamp)
        receive do

           {:pick_starting, {areas, _}} ->
                send outputter, {:message, pick_random areas}
           {:place_armies, state} ->
                msg = place_armies_randomly_at_one_location(state)
                send outputter, {:message, msg}
           {:attack_transfer, state} ->
                msg = attack_randomly(state)
                send outputter, {:message, msg}
           _ ->
                send outputter, {:error, "Invalid Message Received"}
        end
        recv(outputter)
    end

end
