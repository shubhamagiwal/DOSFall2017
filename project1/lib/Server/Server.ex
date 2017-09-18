
defmodule Project1.Server do
        @workload 1000000
        @worker 128
        @startvalue 0
        @endvalue 0
      
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
        keep_server_alive(@startvalue,@startvalue+@workload,elem(tuple,1))
       end

       def keep_server_alive(start_value,end_value,k) do
           
          receive do
          {:getWorkload,nodeName,nodePid} ->
                                     Process.sleep(1000)
                                     send(nodePid,{:hereworkload,nodeName,nodePid,k,start_value,end_value,@workload,@worker})
                                     start_value=start_value+@workload
                                     end_value=end_value+@workload
                        
          {:ok,serverPid} ->   send(serverPid,{:ok,serverPid,start_value,end_value,k})
                               start_value=start_value+@workload
                               end_value=end_value+@workload

          {:ok,pid,startvalue,endvalue,k} ->
                                            spawn(fn -> Project1.Worker.get_bit_coins(k,startvalue,endvalue,pid) end)

          {:getnew,pid} -> #{newstartvalue,newendValue}=spawn_processes(k,start_value,end_value,0,pid)
                           Process.sleep(1000)
                           send(pid,{:sendNew,k,start_value,end_value,pid})
                           start_value=start_value+@workload
                           end_value=end_value+@workload

          {:bitcoinfound,random_string,hash} -> IO.puts to_string(random_string)<>"\t"<>to_string(hash)
          end

           keep_server_alive(start_value,end_value,k)
       end

       def spawn_processes(k,start_value,end_value,times,pid) do
             times=String.to_integer(to_string(:erlang.system_info(:logical_processors)))*@worker
             start=1
             if(start<times) do
                spawn(fn -> Project1.Worker.get_bit_coins(k,start_value,end_value,pid) end)
                start_value=start_value+@workload
                end_value=end_value+@workload
                spawn_processes(k,start_value,end_value,times,pid)
             end
             {start_value,end_value}
       end

    end