defmodule Project1.Server do

    def start(tuple) do
     serverName=String.to_atom(to_string("server@")<>elem(tuple,0))
     IO.inspect serverName
     {:ok,serverpid}=Node.start(serverName)
     cookie=Application.get_env(:project1, :cookie)
     Node.set_cookie(cookie)
     tup_worker={Node.self,elem(tuple,1)}
    end

end