
defmodule Project1.Server do
        @workload 1000000
        @worker 4
        @startvalue 0
        @endvalue 0
      
       def start(tuple) do
        serverName=String.to_atom(to_string("server@")<>elem(tuple,0))
        IO.inspect serverName
        {:ok,serverpid}=Node.start(serverName)
        cookie=Application.get_env(:project1, :cookie)
        Node.set_cookie(cookie)
        #IO.inspect self
        :global.register_name(:server,self)
        send(self,{:ok,self})
        #IO.puts elem(tuple,1)
        keep_server_alive(@startvalue,@startvalue+@workload,elem(tuple,1))
       end

       def keep_server_alive(start_value,end_value,k) do
           
          receive do
          {:getWorkload,clientName,clientPid} ->
                                     Process.sleep(1000)
                                     #IO.inspect clientPid
                                     send(clientPid,{:hereworkload,k,start_value,end_value,@workload,@worker})
                                     start_value=start_value+@workload
                                     end_value=end_value+@workload
                        
          {:ok,serverPid} ->   send(serverPid,{:ok,serverPid,start_value,end_value,k})
                               start_value=start_value+@workload
                               end_value=end_value+@workload

          {:ok,pid,startvalue,endvalue,k} -> spawn_processes(k,start_value,end_value,0,pid,0)

          {:getnew,pid} -> send(pid,{:sendnew,k,start_value,end_value,pid})
                           start_value=start_value+@workload
                           end_value=end_value+@workload

          {:getWorkloadForClientProcessId,clientPid,clientProcessId} -> 
            #IO.puts "Sent new workload to clientProcess Id"
            send(clientPid,{:newWorkloadForClientProcess,k,start_value,end_value,clientProcessId})
            start_value=start_value+@workload
            end_value=end_value+@workload

          {:bitcoinfound,random_string,hash} -> IO.puts to_string(random_string)<>"\t"<>to_string(hash)


          end

           keep_server_alive(start_value,end_value,k)
       end

       def spawn_processes(k,start_value,end_value,times,pid,startvalue) do
             times=String.to_integer(to_string(:erlang.system_info(:logical_processors)))*@worker
             start=startvalue
             if(start<times) do
                spawn(fn -> Project1.Worker.get_bit_coins(k,start_value,end_value,pid) end)
                start_value=start_value+@workload
                end_value=end_value+@workload
                times=times+1
                spawn_processes(k,start_value,end_value,times,pid,startvalue+1)
             end
       end

    end