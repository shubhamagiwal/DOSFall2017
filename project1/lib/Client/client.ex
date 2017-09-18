defmodule Project1.Client do

    def generate_name(ipaddress) do
        machine = to_string("localhost")
        hex = :erlang.monotonic_time() |>
          :erlang.phash2(256) |>
          Integer.to_string(16)
        String.to_atom("#{machine}-#{hex}@#{ipaddress}")
      end
    
    def start_client(ip_address)do
        clientName=generate_name(ip_address)
        {:ok,clientpid}=Node.start(clientName)
        cookie=Application.get_env(:project1, :cookie)
        Node.set_cookie(cookie)
        tuple={Node.self,ip_address}
    end

    def connect_to_server(tuple)do
        Node.connect(String.to_atom(to_string("server@"<>elem(tuple,1))));
        :global.sync()
        send(:global.whereis_name(:server),{:ok,Node.self,self})
        start_worker_client(String.to_atom(to_string("server@"<>elem(tuple,1))))
    end

    def start_worker_client(name) do
    
        receive do
        {:ok,nodeName,k,serverProcess} -> processes=String.to_integer(to_string(:erlang.system_info(:logical_processors)))*8
                                          spawn_processes(processes,0,k)        
        end
        start_worker_client(name)
    end

    def spawn_processes(processes,times,k) do
        if processes>times do
            IO.puts times
            spawn(fn-> Project1.Worker.startWorker({Node.self,k}) end) 
            spawn_processes(processes,times+1,k)
        end
    end
end