defmodule Project3.Boss do
use GenServer
@gossip 10
@pushsumcount 3

 def start_boss(server_tuple) do
        serverName=String.to_atom(to_string("server@")<>elem(server_tuple,0))
        {:ok,_}=Node.start(serverName)
        cookie=Application.get_env(:project3, :cookie)
        Node.set_cookie(cookie)

        numNodes=String.to_integer(to_string(Enum.at(elem(server_tuple,1),0)))
        numRequest=String.to_integer(to_string(Enum.at(elem(server_tuple,1),1)))

        #Spawn Nodes for given number of nodes
        #Here we are not going to run for more than a 100 thousand nodes  to restricting the node space to 100000
        number=1..100000
        list=spawn_nodes(numNodes,1,[],[],Enum.to_list(number))
        IO.inspect list
 end

 def spawn_nodes(numNodes,start_value,l,list_nodesidspace_used,nodeIdSpace_list) do
             if(start_value<=numNodes) do
                random_node_id=Enum.random(nodeIdSpace_list)
                l=l++[Project3.Node.start(random_node_id)]
                start_value=start_value+1
                nodeIdSpace_list=nodeIdSpace_list--[random_node_id]
                l=spawn_nodes(numNodes,start_value,l,list_nodesidspace_used,nodeIdSpace_list)
             end
             l
end



end