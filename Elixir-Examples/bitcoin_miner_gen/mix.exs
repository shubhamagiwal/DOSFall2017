defmodule BitcoinMinerGen.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bitcoin_miner_gen,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      escript: [ main_module: BitcoinMinerGen ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      env: [cookie: :awesome] # Used to set environment variables
    ] 
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
     {:dialyxir, "~> 0.4", only: [:dev]}
    ]
  end
end
