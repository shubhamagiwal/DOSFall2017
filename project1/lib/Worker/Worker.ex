defmodule Project1.Worker do
    use Supervisor
    
        def startWorker(tup_worker) do
            IO.puts "Check here"
            IO.inspect tup_worker
            Node.spawn(elem(tup_worker,0),fn -> Project1.Worker.start_link(elem(tup_worker,1)) end)
        end

        def start_link(value) do
            Supervisor.start_link(__MODULE__, [value])
        end

        def init([value]) do
            children = [
              worker(Project1.Worker, [value], restart: :permanent, function: :spawn_bitcoin),
              ]
            supervise(children, strategy: :one_for_one)
        end


        def spawn_bitcoin(value) do
            pid=spawn(__MODULE__, :bitcoin_miner, [value])
            send(pid,{:ok})
        end

        def bitcoin_miner(value) do
            get_bit_coins(value)
            bitcoin_miner(value);
        end

        def get_bit_coins(value) do
            #value="5"
            randomString=(to_string("shubhamagiwal92;")<>SecureRandom.base64(32));
            hash=:crypto.hash(:sha256,randomString) |> Base.encode16
            status=String.slice(hash,0..String.to_integer(value)-1) |> check ;
            print_bit_coin(status,randomString,hash)
        end

          def check(partOfHash) do
              Enum.all?(String.graphemes(partOfHash),fn(x) -> x=="0" end);
          end

          def print_bit_coin(status,randomString,hash) do
              case status do
                   true->  IO.puts "#{randomString}  #{hash}"
                    _-> :ok
              end 
          end

end