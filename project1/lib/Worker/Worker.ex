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
            pid=spawn(__MODULE__, :bitcoin_miner, [])
            send(pid,{:ok})
        end

        def bitcoin_miner() do
            getBitCoins()
            bitcoin_miner();
        end

        def getBitCoins() do
            value="5"
            randomString=(to_string("shubhamagiwal92;")<>SecureRandom.base64(32));
            hash=:crypto.hash(:sha256,randomString) |> Base.encode16
            status=String.slice(hash,0..String.to_integer(value)-1) |> check ;
            printBitCoin(status,randomString,hash)
        end

          def check(partOfHash) do
              Enum.all?(String.graphemes(partOfHash),fn(x) -> x=="0" end);
          end

          def printBitCoin(status,randomString,hash) do
              case status do
                   true->  IO.puts "#{randomString}  #{hash}"
                    _-> :ok
              end 
          end

end