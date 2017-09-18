
defmodule Project1.Server do
        use Agent
    
        def start(tuple) do
         serverName=String.to_atom(to_string("server@")<>elem(tuple,0))
         IO.inspect serverName
         {:ok,serverpid}=Node.start(serverName)
         cookie=Application.get_env(:project1, :cookie)
         Node.set_cookie(cookie)
         IO.inspect self
         :global.register_name(:server,self)
         processes=String.to_integer(to_string(:erlang.system_info(:logical_processors)))*8
         #1..processes |> Enum.map fn-> spawn(Project1.Worker.startWorker({Node.self,elem(tuple,1)})) end
         spawn_processes(processes,0,elem(tuple,1))
         loop(elem(tuple,0),elem(tuple,1))
        end
    
         def loop(name,k) do

            receive do
                {:ok,nodeName,pid} ->IO.inspect nodeName
                                     pid1=Node.spawn(nodeName, fn-> Project1.Client.start_worker_client(name) end)
                                     send(pid1,{:ok,nodeName,k,self})
             end

            loop(name,k)
        end

        def spawn_processes(processes,times,k)do
             if processes>times do
                 IO.puts times
                 spawn(fn-> Project1.Worker.startWorker({Node.self,k}) end) 
                 spawn_processes(processes,times+1,k)
             end

        end
    
    end