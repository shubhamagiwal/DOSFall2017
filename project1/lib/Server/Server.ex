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
     
     receive do
        {:ok,pid}-> IO.inspect pid
        send(pid, {:ok,elem(tuple,1)})
     end
     
     donotexit
    end

    def donotexit do
        donotexit
    end


end