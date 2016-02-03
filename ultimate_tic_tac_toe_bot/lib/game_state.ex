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
        %{:timebank => 0, :time_per_move=>0,
          :max_rounds=> 0, :bot_name =>"", :opponent_bot_name => "",
          :starting_armies => 0,
          :starting_regions => [],
          :starting_pick_amount => 0,
          :map => %{},
          :neighbors => %{},
          :ownership => %{},
          :opponent_starting_regions => [],
          :last_opponent_moves => []}
    end

    GameStateMacro.create_updater "timebank"
    GameStateMacro.create_updater "time_per_move"
    GameStateMacro.create_updater "max_rounds"
    GameStateMacro.create_updater "bot_name"
    GameStateMacro.create_updater "opponent_bot_name"
    GameStateMacro.create_updater "starting_armies"
    GameStateMacro.create_updater "starting_regions"
    GameStateMacro.create_updater "starting_pick_amount"


    GameStateMacro.create_updater "opponent_starting_regions"
    GameStateMacro.create_updater "last_opponent_moves"

    def set_super_regions(state, super_regions) do
      regions = for [super_region, bonus] <- super_regions, into: %{}, do: {super_region, %{:bonus_armies => bonus, :regions => []}}
      %{state | :map => regions}
    end

    defp update_neighbors({region, neighbors}, state) do
       List.foldl(neighbors, state,
                            fn neighbor, state ->
                                  put_in state, [:neighbors, neighbor],
                                       (if state.neighbors[neighbor] == nil do
                                           [region]
                                        else
                                           state.neighbors[neighbor] ++ [region]
                                        end)
                            end)
    end

    def set_neighbors(state, neighbors) do
       new_state=  %{state | :neighbors => neighbors}
       List.foldl(Map.to_list(neighbors), new_state, &update_neighbors/2)
    end

    defp put_in_region({super_region, regions}, state) do
       put_in state, [:map, super_region, :regions], regions
    end

    defp update_regions(state, regions) do
      List.foldl(regions, state, &put_in_region/2 )
    end

    defp set_initial_ownership(state, regions) do
       all_regions = regions |> Enum.map(&(elem(&1, 1))) |> List.flatten
       %{state | :ownership => (for region <- all_regions, into: %{}, do: {region, {"neutral", 2} }) }
    end

    def set_regions(state, regions) do
        state |>
        update_regions(regions) |>
        set_initial_ownership(regions)


    end

    defp update_ownership({region, name, armies}, state) do
        put_in state, [:ownership, region], {name, armies}
    end

    defp update_fog_of_war({region, {_, armies}}, state) do
        update_ownership({region, "fog", armies}, state)
    end

    defp get_other_regions(regions, state) do
       region_list = Enum.map(regions, &(elem &1, 0))
       Enum.filter(state.ownership, &(!Enum.find_value(region_list, fn(x) -> x == elem &1, 0 end)))
    end

    def update_map(state, regions) do
        new_state = List.foldl(regions, state, &update_ownership/2)
        List.foldl(get_other_regions(regions, new_state), new_state, &update_fog_of_war/2)
    end

    def set_wastelands(state, wastelands) do
        marked_wastelands = Enum.map(wastelands, &{&1, "neutral", 6})
        update_map(state, marked_wastelands)
    end

    def get_armies(state, region) do
        elem(state.ownership[region], 1)
    end


end
