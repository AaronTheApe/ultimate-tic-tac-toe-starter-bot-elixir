defmodule CommandParser do

  def start(game_engine) do
      {:ok, parser} = Task.start_link(fn->parse_message(game_engine) end)
      parser
  end

  def send_message(parser, m) do
    send parser, {:message, m}
  end

  defp parse(game_engine, ["settings", "timebank", val]), do: send(game_engine, {:initial_timebank, String.to_integer(val)})
  defp parse(game_engine, ["settings", "time_per_move", val]), do: send(game_engine, {:time_per_move, String.to_integer(val)})
  defp parse(game_engine, ["settings", "player_names", val]), do: send(game_engine, {:player_names, String.split(val, ",")})
  defp parse(game_engine, ["settings", "your_bot", val]), do: send(game_engine, {:bot_name, val})
  defp parse(game_engine, ["settings", "your_bot_id", val]), do: send(game_engine, {:bot_id, String.to_integer(val)})

  defp parse(game_engine, ["update", "game", "round", val]), do: send(game_engine, {:game_round, String.to_integer(val)})
  defp parse(game_engine, ["update", "game", "move", val]), do: send(game_engine, {:game_move, String.to_integer(val)})
  defp parse(game_engine, ["update", "game", "field", val]), do: send(game_engine, {:game_field, Enum.map(String.split(val, ","), fn(x) -> String.to_integer(x) end)})
  defp parse(game_engine, ["update", "game", "macroboard", val]), do: send(game_engine, {:game_macroboard, Enum.map(String.split(val, ","), fn(x) -> String.to_integer(x) end)})
  defp parse(game_engine, ["action", "move", val]), do: send(game_engine, {:action_move, String.to_integer(val)})


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
