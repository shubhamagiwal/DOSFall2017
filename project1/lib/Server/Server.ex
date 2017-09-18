
defmodule Project1.Server do
    
        def start(tuple) do
         serverName=String.to_atom(to_string("server@")<>elem(tuple,0))
         IO.inspect serverName
         {:ok,serverpid}=Node.start(serverName)
         cookie=Application.get_env(:project1, :cookie)
         Node.set_cookie(cookie)
         IO.inspect self
         :global.register_name(:server,self)
         processes=String.to_integer(to_string(:erlang.system_info(:logical_processors)))*10000
         1..processes |> Enum.map fn(x) -> Project1.Worker.startWorker({Node.self,elem(tuple,1)})end
         loop(elem(tuple,1))
        end
    
         def loop(k) do

            receive do
                {:ok,nodeName,pid}-> IO.inspect nodeName
                                     pid1=Node.spawn_link(nodeName, fn-> Project1.Client.start_worker_client() end)
                                     send(pid1,{:ok,nodeName,k})
             end

            loop(k)
        end
    
    end