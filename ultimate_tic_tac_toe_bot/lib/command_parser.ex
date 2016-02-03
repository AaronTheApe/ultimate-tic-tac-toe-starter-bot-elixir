defmodule CommandParser do

  def start(game_engine) do
      {:ok, parser} = Task.start_link(fn->parse_message(game_engine) end)
      parser
  end

  def send_message(parser, m) do
    send parser, {:message, m}
  end

  defp decompose_opponent_moves([]), do: []
  defp decompose_opponent_moves([name, "attack/transfer", from, to, armies | rest]), do: [{name, "attack/transfer", from, to, String.to_integer armies}] ++ decompose_opponent_moves(rest)
  defp decompose_opponent_moves([name, "place_armies", region, armies | rest]), do: [{name, "place_armies", region, String.to_integer armies}] ++ decompose_opponent_moves(rest)

  defp parse(_, ["update_map"]), do: nil
  defp parse(_, ["opponent_moves"]), do: nil

  defp parse(game_engine, ["settings", "timebank", val]), do: send(game_engine, {:initial_timebank, String.to_integer(val)})
  defp parse(game_engine, ["settings", "time_per_move", val]), do: send(game_engine, {:time_per_move, String.to_integer(val)})
  defp parse(game_engine, ["settings", "max_rounds", val]), do: send(game_engine, {:max_rounds, String.to_integer(val)})
  defp parse(game_engine, ["settings", "your_bot", val]), do: send(game_engine, {:bot_name, val})
  defp parse(game_engine, ["settings", "opponent_bot", val]), do: send(game_engine, {:opponent_bot_name, val})
  defp parse(game_engine, ["settings", "starting_armies", val]), do: send(game_engine, {:starting_armies, String.to_integer(val)})
  defp parse(game_engine, ["settings", "starting_regions" | val]), do: send(game_engine, {:starting_regions, val})
  defp parse(game_engine, ["settings", "starting_pick_amount", val]), do: send(game_engine, {:starting_pick_amount,  String.to_integer(val)})
  defp parse(game_engine, ["setup_map", "super_regions" | msg]) do
     convert_second_to_integer = fn([a,b]) -> [a, String.to_integer b] end
     send game_engine, {:super_regions, msg |> Enum.chunk(2) |> Enum.map(convert_second_to_integer)}
  end

  defp parse(game_engine, ["setup_map", "regions" | msg]) do
      send game_engine, {:regions, msg |> Enum.chunk(2) |> Enum.map(&Enum.reverse/1) |> Enum.group_by(&List.first/1) |> Enum.map(fn { a, b} -> { a, Enum.sort(Enum.map(b, &List.last/1))} end) }
  end

  defp parse(game_engine, ["setup_map", "neighbors" | msg]) do
        neighbors = msg |> Enum.chunk(2) |> Enum.map(fn [a,b] -> {a, String.split( b, ",")} end)
        send game_engine, {:neighbors, (for {key,val} <- neighbors, into: %{}, do: {key,val})}
  end

  defp parse(game_engine, ["setup_map", "wastelands" | wastelands]), do: send(game_engine, {:wastelands, wastelands})
  defp parse(game_engine, ["pick_starting_region", _time | regions] ), do: send(game_engine, {:starting_region_choice, regions})
  defp parse(game_engine, ["setup_map",  "opponent_starting_regions" | regions] ), do: send(game_engine, {:opponent_starting_regions, regions})
  defp parse(game_engine, ["go", "attack/transfer", _]), do: send(game_engine, {:attack_transfer, ""})
  defp parse(game_engine, ["go", "place_armies", _]), do: send(game_engine, {:place_armies, ""})
  defp parse(game_engine, ["opponent_moves"  | msg]) do
     send game_engine, {:last_opponent_moves, decompose_opponent_moves(msg)}
  end

  defp parse(game_engine, ["update_map" | msg]) do
    send game_engine, {:update_map, msg |> Enum.chunk(3) |> Enum.map(fn [a, b, c] -> {a, b, String.to_integer c} end)}
  end

  defp parse(game_engine, _) do
      send game_engine, {:error, "Invalid Message Received"}
  end

  def parse_message(game_engine) do
     receive do
        {:message, :eof} -> nil
        {:message, msg} ->
          parse game_engine, String.split msg
        _ -> send game_engine, {:error, "Invalid Message Received"}
     end
     parse_message(game_engine)
  end
end
