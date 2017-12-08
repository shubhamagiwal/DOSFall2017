defmodule Project4Part2.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, args) do
    import Supervisor.Spec

    IO.inspect args

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(Project4Part2Web.Endpoint, []),
      # Start your own worker by calling: Project4Part2.Worker.start_link(arg1, arg2, arg3)
      # worker(Project4Part2.Node, []) 
      worker(Project4Part2.Boss, []) 

    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Project4Part2.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Project4Part2Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
