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
        send(:global.whereis_name(:server),{:getWorkload,Node.self,self})
        start_worker_client(String.to_atom(to_string("server@"<>elem(tuple,1))))
    end

    def start_worker_client(name) do
    
        receive do
            {:hereworkload,k,start_value,end_value,workload,noOfWorkers} -> 
                IO.puts start_value
                IO.puts end_value
                IO.inspect self
                spawn_processes_client(k,start_value,end_value,0,workload,noOfWorkers,self)
            # {:getnew,pid} -> send(:global.whereis_name(:server),{:getWorkload,Node.self,pid})
            {:getnew,clientprocesspid} ->  IO.puts "Client process ID new Workload"
                send(:global.whereis_name(:server),{:getWorkloadForClientProcessId,self,clientprocesspid})
            {:newWorkloadForClientProcess,k,start_value,end_value,clientProcessId}-> 
                IO.puts "Sending workload to new Client process id"
                send(clientProcessId,{:sendnew,k,start_value, end_value,self})
            end
            start_worker_client(name)
    end

    def spawn_processes_client(k,start_value,end_value,startValue,workload,workers,clientId) do
        IO.puts "Spawn"
        times=String.to_integer(to_string(:erlang.system_info(:logical_processors)))*1
        start=startValue
        spawn(fn -> Project1.Worker.get_bit_coins(k,start_value,end_value,clientId) end)
        # if(start<times) do
        #    spawn(fn -> Project1.Worker.get_bit_coins(k,start_value,end_value,self) end)
        #    start_value=start_value+workload
        #    end_value=end_value+workload
        #    times=times+1
        #    spawn_processes_client(k,start_value,end_value,times,workload,workers)
        # end
    end
end