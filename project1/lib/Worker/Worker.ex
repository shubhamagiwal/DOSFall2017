defmodule Project1.Worker do
    use Supervisor
    
        def startWorker(tup_worker) do
            
            Node.spawn(elem(tup_worker,0),fn -> Project1.Worker.start_link(tup_worker) end)
            
        end

        def start_link(tup_worker) do
            Supervisor.start_link(__MODULE__, [elem(tup_worker,0),elem(tup_worker,1)])
            
        end

        def init(tup_worker) do
            children = [
              worker(Project1.Worker, [tup_worker], restart: :permanent, function: :spawn_bitcoin),
              ]
            supervise(children, strategy: :one_for_one)
        end


        def spawn_bitcoin(tup_worker) do
             send(spawn(__MODULE__, :bitcoin_miner, [tup_worker]),{:ok})
        end

        def bitcoin_miner(tup_worker) do
            getBitCoins(List.last(tup_worker),List.first(tup_worker))
            bitcoin_miner(tup_worker)
        end

        def getBitCoins(k, str) do
            value=k
            randomString=(to_string("shubhamagiwal92;")<>SecureRandom.base64(32));
            hash=:crypto.hash(:sha256,randomString) |> Base.encode16
            status=String.slice(hash,0..String.to_integer(value)-1) |> check ;
            printBitCoin(status,randomString,hash,str)
        end

          def check(partOfHash) do
              Enum.all?(String.graphemes(partOfHash),fn(x) -> x=="0" end);
          end

          def printBitCoin(status,randomString,hash,str) do
              case status do
                   true->  IO.puts "#{randomString} #{str}  #{hash}"
                    _-> :ok
              end 
          end

end
