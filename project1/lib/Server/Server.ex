
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
<<<<<<< HEAD
         processes=String.to_integer(to_string(:erlang.system_info(:logical_processors)))*10000
=======
         processes=String.to_integer(to_string(:erlang.system_info(:logical_processors)))*8
>>>>>>> 0a70dcd74ff843a4f7065224a949c4727a45e4a8
         1..processes |> Enum.map fn(x) -> Project1.Worker.startWorker({Node.self,elem(tuple,1)})end
         loop(elem(tuple,0),elem(tuple,1))
        end
    
         def loop(name,k) do

            receive do
                {:ok,nodeName,pid}-> IO.inspect nodeName
                                     pid1=Node.spawn(nodeName, fn-> Project1.Client.start_worker_client(name) end)
                                     send(pid1,{:ok,nodeName,k,self})
             end

            loop(name,k)
        end
    
    end