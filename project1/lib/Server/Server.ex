defmodule Project1.Server do

    def start(ipaddress) do
     serverName=String.to_atom(to_string("server@")<>ipaddress)
     IO.inspect serverName
     {:ok,serverpid}=Node.start(serverName)
     cookie=Application.get_env(:project1, :cookie)
     Node.set_cookie(cookie)
     Node.self
    end

end