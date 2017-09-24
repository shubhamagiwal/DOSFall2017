defmodule Examplemix.Mixfile do
  use Mix.Project

  def project do
    [
      app: :examplemix,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      escript: [main_module: Examplemix],
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
       {:secure_random, "~> 0.5"},
       {:dialyxir, "~> 0.4", only: [:dev]}
       #{:dep_from_hexpm, "~> 0.3.0"},
       #{:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
       #{:phoenix, "~> 1.1 or ~> 1.2"},
       #{:phoenix_html, "~> 2.3"},
       #{:cowboy, "~> 1.0", only: [:dev, :test]},
       #{:slime, "~> 0.14"}
    ]
  end
end
