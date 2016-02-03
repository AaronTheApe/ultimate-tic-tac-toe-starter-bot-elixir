defmodule UltimateTicTacToeBot.Mixfile do
  use Mix.Project

  def project do
    [app: :ultimate_tic_tac_toe_bot,
     version: "0.0.1",
     elixir: "~> 1.0",
     escript: escript_config,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger],
     mod: {UltimateTicTacToeBot, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    []
  end

  def escript_config do
   [main_module: Bot]
  end
end
