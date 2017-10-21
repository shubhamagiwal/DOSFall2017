defmodule Project3.Boss do
use GenServer
@b 2

def init(:ok) do
        {:ok,%{}}
end

 def start_boss(server_tuple) do
        serverName=String.to_atom(to_string("server@")<>elem(server_tuple,0))
        {:ok,_}=Node.start(serverName)
        cookie=Application.get_env(:project3, :cookie)
        Node.set_cookie(cookie)
        {:ok,pid} = GenServer.start_link(__MODULE__, :ok, name: Boss_Server)  # -> Created the boss process
        numNodes=String.to_integer(to_string(Enum.at(elem(server_tuple,1),0)))
        numRequest=String.to_integer(to_string(Enum.at(elem(server_tuple,1),1)))

        #Spawn Nodes for given number of nodes
        #Here we are not going to run for more than a 100 thousand nodes  to restricting the node space to 100000
        number=1..numNodes
        # Returns a tuple with hash, node id and pid for the every node
        list_of_nodes_with_pids=spawn_nodes(numNodes,1,[],[],Enum.to_list(number))
        # Returns a tuple with hash, node id and pid for the every node in ascending order of their node ids to start with the topology
        list_of_nodes_with_pids=Enum.sort(list_of_nodes_with_pids,fn(x,y) -> elem(x,2)<elem(y,2)  end)
        #IO.inspect list_of_nodes_with_pids

        #Building the topology
        build_topology(list_of_nodes_with_pids,numRequest)
        send_to_node(list_of_nodes_with_pids, numNodes, 0)
 end

 def send_to_node(list_of_nodes, num_nodes, counter) do
        if(counter < num_nodes) do
        random_node = Enum.random(list_of_nodes) # Get a randome node
        list_of_nodes = list_of_nodes -- [random_node] # Update list
        counter = counter+1 # Update counter
        node_id = elem(random_node,2)
        count = 0
        node_list_count = num_nodes
        process_id = elem(random_node,0)
        hash = elem(random_node,1)
        #Genserver.cast(process_id,{:receive_request_to_cast,node_id,count,node_list_count,process_id,hash,@b})
        send_to_node(list_of_nodes, num_nodes, counter)
        end
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

def random_node do
        random_node_id = Enum.random(100..9999999)
        hash=:crypto.hash(:sha, to_string(random_node_id)) 
                |> Base.encode16 
                |> Convertat.from_base(16) 
                |> Convertat.to_base(4)
        hash
end



def build_topology(list_of_nodes_with_pids,numRequest) do

        Enum.each(Enum.with_index(list_of_nodes_with_pids),fn(x)->
                larger_leaf_set=Project3.Node.larger_leaf_set(list_of_nodes_with_pids,elem(x,1),@b,[])
                smaller_leaf_set=Project3.Node.smaller_leaf_set(list_of_nodes_with_pids,elem(x,1),@b,[])
                neighbor_set = Project3.Node.neighbor_set(list_of_nodes_with_pids, elem(x,1), 0, [])
                routing_table=Project3.Node.create_routing_table_for_a_node(@b,elem(elem(x,0),1),list_of_nodes_with_pids)
                GenServer.cast(elem(elem(x,0),0),{:updateLeafSet,larger_leaf_set,smaller_leaf_set,neighbor_set,routing_table,numRequest})
         end)

end

end