defmodule Sequence do
  use Application

  def start() do
    import Supervisor.Spec, warn: false
    children = [
         worker(Sequence.Server, [123])
    ]
    opts = [strategy: :one_for_one]
    {:ok, _pid} = Supervisor.start_link(children, opts)
    IO.inspect(_pid)
    IO.inspect Supervisor.which_children(_pid)
    [one]=Supervisor.which_children(_pid) 
    {_,one_pid,_,_}=one;
    IO.inspect Sequence.Server.next(one_pid)
    IO.inspect Sequence.Server.next(one_pid)
    GenServer.stop(one_pid);
    IO.inspect Process.alive?(one_pid)
    [one]=Supervisor.which_children(_pid) 
    {_,one_pid,_,_}=one;
    IO.inspect one_pid
  end
  

  def main(args \\ []) do
      start()

      donotexit()
  end

  def donotexit() do
      donotexit()
  end


end
