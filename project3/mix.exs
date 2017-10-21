defmodule Project3.Mixfile do
  use Mix.Project

  def project do
    [
      app: :project3,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      escript: [main_module: Project3],
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      env: [cookie: :awesome]

    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Using the hex package manager:
      {:convertat, "~> 1.0"},
      # or grabbing the latest version (master branch) from GitHub:
      #{:convertat, github: "whatyouhide/convertat"},
    ]
  end
end
