defmodule Project2.Server do

    def start_server_node(server_tuple) do
        serverName=String.to_atom(to_string("server@")<>elem(server_tuple,0))
        {:ok,serveepmdrpid}=Node.start(serverName)
        cookie=Application.get_env(:project1, :cookie)
        Node.set_cookie(cookie)
        :global.register_name(:server,self)
       IO.inspect spawn_processes(String.to_integer(to_string(Enum.at(elem(server_tuple,1),0))),1,[])

    end

   def spawn_processes(numNodes,start_value,l) do
             if(start_value<=numNodes) do
                l=l++[start(start_value)]
                start_value=start_value+1
                l=spawn_processes(numNodes,start_value,l)
             end
             l
    end

   # Genserver processes start
   def start(start_value) do
        {:ok,pid} = GenServer.start_link(__MODULE__,[],name: String.to_atom(to_string(start_value)))
        pid
    end

    #Server Side Implementation
    def init(args) do
        {:ok,{}}
    end

end