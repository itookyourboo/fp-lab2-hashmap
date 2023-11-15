defmodule FpLab2Hashmap.MixProject do
  use Mix.Project

  def project do
    [
      app: :fp_lab2_hashmap,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        # Put the project-level PLT in the priv/ directory (instead of the default _build/ location)
        plt_file: {:no_warn, "priv/plts/project.plt"}

        # The above is equivalent to:
        # plt_local_path: "priv/plts/project.plt"

        # You could also put the core Erlang/Elixir PLT into the priv/ directory like so:
        # plt_core_path: "priv/plts/core.plt"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:stream_data, "~> 0.6.0", only: [:dev, :test]},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
