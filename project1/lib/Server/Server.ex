defmodule Project1.Server do

    def start(tup) do
     serverName=String.to_atom(to_string("server@")<>elem(tup,0))
     IO.inspect serverName
     {:ok,serverpid}=Node.start(serverName)
     cookie=Application.get_env(:project1, :cookie)
     Node.set_cookie(cookie)
     tup_worker={Node.self,elem(tup,1)}
    end

end