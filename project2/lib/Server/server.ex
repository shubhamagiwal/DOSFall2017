defmodule Project2.Server do
use GenServer

    def start_server_node(server_tuple) do
        serverName=String.to_atom(to_string("server@")<>elem(server_tuple,0))
        {:ok,serveepmdrpid}=Node.start(serverName)
        cookie=Application.get_env(:project1, :cookie)
        Node.set_cookie(cookie)
        list=spawn_processes(String.to_integer(to_string(Enum.at(elem(server_tuple,1),0))),1,[])
        GenServer.cast(Enum.at(list,0),{:got,"Awesome"})
        GenServer.cast(Enum.at(list,1),{:got,"Awesome2"})
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
        {:ok,%{}}
    end

    def handle_cast({:got,msg},state) do
        IO.puts msg;
        {:noreply,state}
    end

end