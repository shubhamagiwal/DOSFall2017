defmodule Project1.Worker do
    use Supervisor
    
        def startWorker(node) do
            Node.spawn(node,fn -> Project1.Worker.start_link() end)
        end

        def start_link() do
            Supervisor.start_link(__MODULE__, [])
        end

        def init([]) do
            children = [
              worker(Project1.Worker, [], restart: :permanent, function: :spawn_bitcoin),
              ]
            supervise(children, strategy: :one_for_one)
        end


        def spawn_bitcoin() do
            pid=spawn_link(__MODULE__, :bitcoin_miner, [])
            IO.inspect "Bitcoin miner #{pid}"
            send(pid,{:ok})
        end

        def bitcoin_miner() do
            IO.puts "Awesome"
            bitcoin_miner();
        end

end