defmodule Project1.Worker do
    use Supervisor
    
        def startWorker(tup_worker) do
            Node.spawn(elem(tup_worker,0),fn -> Project1.Worker.start_link(elem(tup_worker,1)) end)
        end

        def start_link(k) do
            Supervisor.start_link(__MODULE__, [k])
        end

        def init(k) do
            children = [
              worker(Project1.Worker, [k], restart: :permanent, function: :spawn_bitcoin),
              ]
            supervise(children, strategy: :one_for_one)
        end


        def spawn_bitcoin(k) do
             send(spawn(__MODULE__, :bitcoin_miner, [k]),{:ok})
        end

        def bitcoin_miner(k) do
            getBitCoins(k)
            bitcoin_miner(k)
        end

        def getBitCoins(k) do
            value=to_string(k)
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