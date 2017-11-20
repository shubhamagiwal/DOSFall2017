defmodule Project3.Boss do
use GenServer
@b 2

def init(:ok) do
        {:ok,%{}}
end

def handle_cast({:update_boss_state,numRequest,numNodes,list_of_nodes_with_pids},state) do
        {_,state_numRequest}=Map.get_and_update(state,:numRequest, fn current_value -> {current_value,numRequest} end)
        {_,state_numNodes}=Map.get_and_update(state,:numNodes, fn current_value -> {current_value,numNodes} end)
        {_,state_list_of_nodes_with_pids}=Map.get_and_update(state,:list_of_nodes_with_pids, fn current_value -> {current_value,list_of_nodes_with_pids} end)
        {_,state_hops_count}=Map.get_and_update(state,:hop_count, fn current_value -> {current_value,0} end)
        {_,state_total_request_received}=Map.get_and_update(state,:total_request_received, fn current_value -> {current_value,0} end)

      
        state=Map.merge(state,state_numRequest)
        state=Map.merge(state,state_numNodes)
        state=Map.merge(state,state_list_of_nodes_with_pids)
        state=Map.merge(state,state_hops_count)
        state=Map.merge(state,state_total_request_received)

        #IO.inspect state

        {:noreply,state}

end

def handle_cast({:update_boss_state,dead_list,alive_list},state) do
        {_,state_alivelist}=Map.get_and_update(state,:alive_list, fn current_value -> {current_value,alive_list} end)
        state=Map.merge(state,state_alivelist)
        {_,state_deadlist}=Map.get_and_update(state,:dead_list, fn current_value -> {current_value,alive_list} end)
        state=Map.merge(state,state_deadlist)
        {_,state_numNodes}=Map.get_and_update(state,:numNodes, fn current_value -> {current_value,length(alive_list)} end)
        state=Map.merge(state,state_numNodes)

        #IO.inspect state

        {:noreply,state}
end

def handle_cast({:delivered,hopcount,process,hash},state) do
     #IO.puts "#{inspect process} #{inspect hash} total-requested= #{state[:total_request_received]} hopcount= #{state[:hop_count]}"
     #IO.puts "#{inspect state[:total_request_received]} #{inspect (state[:numRequest] * state[:numNodes])}"

     {_,state_hop_count}=Map.get_and_update(state,:hop_count, fn current_value -> {current_value,current_value+hopcount} end)
     state=Map.merge(state,state_hop_count)
     {_,state_total_request_received}=Map.get_and_update(state,:total_request_received, fn current_value -> {current_value,current_value+1} end)
     state=Map.merge(state,state_total_request_received)

    # IO.inspect state

     if(state[:total_request_received]>=(state[:numRequest] * state[:numNodes]) and (state[:numRequest] * state[:numNodes])>0) do
        average_hop_count=state[:hop_count]/(state[:numRequest] * state[:numNodes])
        IO.puts "The average hop count is #{inspect average_hop_count}"
        Process.exit(self(),:normal)
     end

     if( (state[:numRequest] * state[:numNodes])==0) do
         IO.puts "The average hop count is 0"
          Process.exit(self(),:normal)
     end

    {:noreply,state}

end

 def start_boss(server_tuple) do
        serverName=String.to_atom(to_string("server@")<>elem(server_tuple,0))
        {:ok,_}=Node.start(serverName)
        cookie=Application.get_env(:project3, :cookie)
        {:ok,_} = GenServer.start_link(__MODULE__, :ok, name: Boss_Server)  # -> Created the boss process
        Node.set_cookie(cookie)

        numNodes=String.to_integer(to_string(Enum.at(elem(server_tuple,1),0)))
        numRequest=String.to_integer(to_string(Enum.at(elem(server_tuple,1),1)))
        pct = String.to_integer(to_string(Enum.at(elem(server_tuple,1),2)))
        nodes_to_kill = round((pct*numNodes)/100) # Number of nodes to be killed

        #Spawn Nodes for given number of nodes
        #Here we are not going to run for more than a 100 thousand nodes  to restricting the node space to 100000
        number=1..numNodes
        # Returns a tuple with hash, node id and pid for the every node
        list_of_nodes_with_pids=spawn_nodes(numNodes,1,[],[],Enum.to_list(number))
        # Returns a tuple with hash, node id and pid for the every node in ascending order of their node ids to start with the topology
        list_of_nodes_with_pids=Enum.sort(list_of_nodes_with_pids,fn(x,y) -> elem(x,2)<elem(y,2)  end)
    
        #Initialising the boss
         GenServer.cast(Boss_Server,{:update_boss_state,numRequest,numNodes,list_of_nodes_with_pids})
        #Building the topology
        build_topology(list_of_nodes_with_pids,numRequest)

        #Kill Nodes
        killed_nodes=kill_nodes(list_of_nodes_with_pids, nodes_to_kill, [])
        alive_nodes = list_of_nodes_with_pids -- killed_nodes

        #updating the boss state
        killed_nodes=Enum.sort(killed_nodes,fn(x,y) -> elem(x,2)<elem(y,2)  end)
        alive_nodes=Enum.sort(alive_nodes,fn(x,y) -> elem(x,2)<elem(y,2)  end)
        GenServer.cast(Boss_Server,{:update_boss_state,killed_nodes,alive_nodes})
                
        send_to_node(alive_nodes,length(alive_nodes), 0,killed_nodes,alive_nodes,list_of_nodes_with_pids)
        

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

 def send_to_node(list_of_nodes, num_nodes, counter,killed_nodes,alive_nodes,list_nodes_pid) do
        #IO.inspect length(alive_nodes)
        if(counter < num_nodes and length(alive_nodes)>1)do
                 random_node = Enum.random(list_of_nodes) # Get a randome node
                 list_of_nodes = list_of_nodes -- [random_node] # Update list
                 counter = counter+1 # Update counter
                 node_id = elem(random_node,2)
                 count = 0
                 node_list_count = num_nodes
                 process_id = elem(random_node,0)
                 hash = elem(random_node,1)
                 GenServer.cast(process_id,{:receive_request_to_cast,node_id,count,node_list_count,process_id,hash,@b,killed_nodes,alive_nodes,list_nodes_pid})
                 send_to_node(list_of_nodes, num_nodes, counter,killed_nodes,alive_nodes,list_nodes_pid)
        else if( length(alive_nodes)==1) do
               GenServer.cast(elem(Enum.at(alive_nodes,0),0),{:sendHopCountDirect,@b})
        else if(length(alive_nodes)==0) do
               #IO.puts "I am here"
               GenServer.cast(Boss_Server,{:delivered,0,nil,nil})
             end
           end
        end
 end

 def spawn_nodes(numNodes,start_value,l,list_nodesidspace_used,nodeIdSpace_list) do
             if(start_value<=numNodes) do
                random_node_id=Enum.random(nodeIdSpace_list)
                l=l++[Project3.Node.start(random_node_id,@b)]
                start_value=start_value+1
                nodeIdSpace_list=nodeIdSpace_list--[random_node_id]
                l=spawn_nodes(numNodes,start_value,l,list_nodesidspace_used,nodeIdSpace_list)
             end
             l
end

def build_topology(list_of_nodes_with_pids,numRequest) do

        Enum.each(Enum.with_index(list_of_nodes_with_pids),fn(x)->
                larger_leaf_set=Project3.Node.larger_leaf_set(list_of_nodes_with_pids,elem(x,1),@b,[])
                smaller_leaf_set=Project3.Node.smaller_leaf_set(list_of_nodes_with_pids,elem(x,1),@b,[])
                neighbor_set = Project3.Node.neighbor_set(list_of_nodes_with_pids, elem(x,1), 0, [])
                routing_table=Project3.Node.create_routing_table_for_a_node(@b,elem(elem(x,0),1),list_of_nodes_with_pids)
                GenServer.cast(elem(elem(x,0),0),{:updateLeafSet,larger_leaf_set,smaller_leaf_set,neighbor_set,routing_table,numRequest,round(:math.log(length(list_of_nodes_with_pids))/:math.log(:math.pow(2,@b))),trunc(:math.pow(2,@b)-1)})
         end)

end

end