
defmodule Project1.Server do
    
        def start(tuple) do
         serverName=String.to_atom(to_string("server@")<>elem(tuple,0))
         IO.inspect serverName
         {:ok,serverpid}=Node.start(serverName)
         cookie=Application.get_env(:project1, :cookie)
         Node.set_cookie(cookie)
         IO.inspect self
         :global.register_name(:server,self)
         Project1.Worker.startWorker({Node.self,elem(tuple,1)})    
         loop(elem(tuple,1))
        end
    
         def loop(k) do
            receive do
                {:ok,nodeName,pid}-> IO.inspect nodeName
                pid1=Node.spawn_link(nodeName, fn->Project1.Worker.startWorker({nodeName,k}) end)
                IO.inspect pid1
                Node.spawn_link(nodeName, fn->Project1.Worker.startWorker({nodeName,k}) end)
                Node.spawn_link(nodeName, fn->Project1.Worker.startWorker({nodeName,k}) end)
                Node.spawn_link(nodeName, fn->Project1.Worker.startWorker({nodeName,k}) end)
                #send(pid, {:ok,elem(tuple,1)})
             end
            loop(k)
        end
    
    end