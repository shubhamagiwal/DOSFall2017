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
        pct = String.to_integer(to_string(Enum.at(elem(server_tuple,1),2)))
        #Spawn Nodes for given number of nodes
        #Here we are not going to run for more than a 100 thousand nodes  to restricting the node space to 100000
        number=1..numNodes
        # Returns a tuple with hash, node id and pid for the every node
        list_of_nodes_with_pids=spawn_nodes(numNodes,1,[],[],Enum.to_list(number))
        # Returns a tuple with hash, node id and pid for the every node in ascending order of their node ids to start with the topology
        list_of_nodes_with_pids=Enum.sort(list_of_nodes_with_pids,fn(x,y) -> elem(x,2)<elem(y,2)  end)
        #IO.inspect list_of_nodes_with_pids
        #Building the topology
        nodes_to_kill = round((pct*numNodes)/100) # Number of nodes to be killed
        build_topology(list_of_nodes_with_pids,numRequest, pct)
        a=kill_nodes(list_of_nodes_with_pids, nodes_to_kill, [])
        new_list = list_of_nodes_with_pids -- a
        update_node_sets(new_list)
        num_nodes = Enum.count(new_list)
        send_to_node(new_list, num_nodes, 0)
 end

 def update_node_sets(new_list) do
        Enum.each(Enum.with_index(new_list),fn(x)->
                larger_leaf_set=Project3.Node.larger_leaf_set(new_list,elem(x,1),@b,[])
                smaller_leaf_set=Project3.Node.smaller_leaf_set(new_list,elem(x,1),@b,[])
                neighbor_set = Project3.Node.neighbor_set(new_list, elem(x,1), 0, [])
                routing_table=Project3.Node.create_routing_table_for_a_node(@b,elem(elem(x,0),1),new_list)
                GenServer.cast(elem(elem(x,0),0),{:updateLeafSet,larger_leaf_set,smaller_leaf_set,neighbor_set,routing_table})
         end)
 end

 def kill_nodes(list, nodes_count, killed_nodes) do
        if( nodes_count > 0) do
                random_node = Enum.random(list)
                pid = elem(random_node,0)
                Process.exit(pid, :normal)
                list = list -- [random_node]
                killed_nodes = killed_nodes ++ [random_node]
                nodes_count = nodes_count-1 
                killed_nodes=kill_nodes(list, nodes_count, killed_nodes)
        end
        killed_nodes
 end

 def send_to_node(list_of_nodes, num_nodes, counter) do
        if(counter < num_nodes) do
        # IO.puts "I am here again"
        # IO.inspect list_of_nodes
        random_node = Enum.random(list_of_nodes) # Get a random node
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


def build_topology(list_of_nodes_with_pids,numRequest,pct) do
        Enum.each(Enum.with_index(list_of_nodes_with_pids),fn(x)->
                larger_leaf_set=Project3.Node.larger_leaf_set(list_of_nodes_with_pids,elem(x,1),@b,[])
                smaller_leaf_set=Project3.Node.smaller_leaf_set(list_of_nodes_with_pids,elem(x,1),@b,[])
                neighbor_set = Project3.Node.neighbor_set(list_of_nodes_with_pids, elem(x,1), 0, [])
                routing_table=Project3.Node.create_routing_table_for_a_node(@b,elem(elem(x,0),1),list_of_nodes_with_pids)
                #IO.puts "I am here"
                # IO.inspect elem(elem(x,0),0)
                # IO.puts "I am here again"
                # IO.inspect elem(x,0)
                #IO.inspect list_of_nodes_with_pids
                GenServer.cast(elem(elem(x,0),0),{:updateLeafSet,larger_leaf_set,smaller_leaf_set,neighbor_set,routing_table,numRequest})
         end)

end

end