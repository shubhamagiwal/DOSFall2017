
defmodule Project1.Server do
        @workload 1000000
        @worker 32
      
       def start(tuple) do
        serverName=String.to_atom(to_string("server@")<>elem(tuple,0))
        IO.inspect serverName
        {:ok,serverpid}=Node.start(serverName)
        cookie=Application.get_env(:project1, :cookie)
        Node.set_cookie(cookie)
        IO.inspect self
        :global.register_name(:server,self)
        send(self,{:ok,self})
        IO.puts elem(tuple,1)
        keep_server_alive(0,100000,elem(tuple,1))
       end

       def keep_server_alive(start_value,end_value,k) do
           
          receive do
          {:ok,nodeName,nodePid} ->  IO.inspect nodeName
                                     send(nodePid,{:ok,nodeName,k,self,start_value,end_value})
                                     start_value=start_value+@workload
                                     end_value=end_value+@workload
                        
          {:ok,serverPid} ->   IO.puts " iam here"
                               send(serverPid,{:ok,serverPid,start_value,end_value,k})
                               start_value=start_value+@workload
                               end_value=end_value+@workload

          {:ok,pid,startvalue,endvalue,k} ->
                                            spawn(fn -> Project1.Worker.get_bit_coins(k,startvalue,endvalue,pid) end)

          {:getnew,pid} -> spawn(fn -> Project1.Worker.get_bit_coins(k,start_value,end_value,pid) end)
                       start_value=start_value+@workload
                       end_value=end_value+@workload
          end

           keep_server_alive(start_value,end_value,k)
       end
    end