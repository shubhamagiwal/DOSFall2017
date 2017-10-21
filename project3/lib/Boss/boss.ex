defmodule Project3.Boss do
use GenServer
@b 4

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
        # Returns a tuple with hash, node id and pid for the every node
        list_of_nodes_with_pids=spawn_nodes(numNodes,1,[],[],Enum.to_list(number))
        # Returns a tuple with hash, node id and pid for the every node in ascending order of their node ids to start with the topology
        list_of_nodes_with_pids=Enum.sort(list_of_nodes_with_pids,fn(x,y) -> elem(x,2)<elem(y,2)  end)
        IO.inspect list_of_nodes_with_pids

        #Building the topology
        build_topology(list_of_nodes_with_pids)
        

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



def build_topology(list_of_nodes_with_pids) do

        Enum.each(Enum.with_index(list_of_nodes_with_pids),fn(x)->
                larger_leaf_set=Project3.Node.larger_leaf_set(list_of_nodes_with_pids,elem(x,1),@b,[])
                smaller_leaf_set=Project3.Node.smaller_leaf_set(list_of_nodes_with_pids,elem(x,1),@b,[])
                IO.puts "Larger set for #{inspect x} = #{inspect larger_leaf_set}"  
                IO.puts "smaller set for #{inspect x} = #{inspect smaller_leaf_set}"  
         end)

end

end