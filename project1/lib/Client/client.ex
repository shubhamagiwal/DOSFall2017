defmodule Project1.Client do
    
    def start_client(ip_address)do
        clientName=generate_name(ip_address)
        {:ok,clientpid}=Node.start(clientName)
        cookie=Application.get_env(:project1, :cookie)
        Node.set_cookie(cookie)
        tuple={Node.self,ip_address}
    end

    def connect_to_server(tuple)do
        IO.inspect Node.connect(String.to_atom(to_string("server@"<>elem(tuple,1)))); 
        IO.inspect Node.list() 
        IO.inspect Node.self
        :global.sync()
        send(:global.whereis_name(:server),{:ok,Node.self,self})
        start_worker_client()
    end

    def generate_name(ipaddress) do
        machine = to_string("localhost")
        hex = :erlang.monotonic_time() |>
          :erlang.phash2(256) |>
          Integer.to_string(16)
        String.to_atom("#{machine}-#{hex}@#{ipaddress}")
      end

    def start_worker_client() do
        receive do
        {:ok,nodeName,k}-> IO.puts " I am Here"
                           Project1.Worker.startWorker({nodeName,k})  
                           Project1.Worker.startWorker({nodeName,k})  
                           Project1.Worker.startWorker({nodeName,k})  
                           Project1.Worker.startWorker({nodeName,k})  
                           Project1.Worker.startWorker({nodeName,k})  
                           Project1.Worker.startWorker({nodeName,k})  
                           Project1.Worker.startWorker({nodeName,k})  
                           Project1.Worker.startWorker({nodeName,k}) 
                           Project1.Worker.startWorker({nodeName,k})  
                           Project1.Worker.startWorker({nodeName,k})  
                           Project1.Worker.startWorker({nodeName,k})  
                           Project1.Worker.startWorker({nodeName,k})  
                           Project1.Worker.startWorker({nodeName,k})  
                           Project1.Worker.startWorker({nodeName,k})  
                           Project1.Worker.startWorker({nodeName,k})  
        end

        start_worker_client()
    end

end