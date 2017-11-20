defmodule Project4Part1.Boss do
use GenServer

 def start_boss(server_tuple) do
        serverName=String.to_atom(to_string("server@")<>elem(server_tuple,0))
        {:ok,_}=Node.start(serverName)
        cookie=Application.get_env(:project3, :cookie)
        {:ok,_} = GenServer.start_link(__MODULE__, :ok, name: Boss_Server)  # -> Created the boss process
        Node.set_cookie(cookie)

        numNodes=String.to_integer(to_string(Enum.at(elem(server_tuple,1),0)))

        # Spawn the given numNodes which is registering an account with a password
        list=spawn_nodes(numNodes,1,[])
        send_list(list,1,numNodes)
 end
 
 def send_list(list, start_value, num_nodes) do
     if(start_value<=num_nodes) do
        name_of_node=String.to_atom("tweeter@user"<>to_string(start_value))
        GenServer.cast(name_of_node,{:receive_list, list, name_of_node})
        start_value=start_value+1
        #IO.puts start_value
        send_list(list, start_value, num_nodes)
     end     
 end

 def spawn_nodes(numNodes,start_value,l) do
        if(start_value<=numNodes) do
            l=l++[Project4Part1.Node.start(start_value)]
            name_of_node=String.to_atom("tweeter@user"<>to_string(start_value))
            GenServer.cast(name_of_node,{:check})
            start_value=start_value+1
            l=spawn_nodes(numNodes,start_value,l)
        end             
        l
end

 
end