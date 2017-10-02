defmodule Project2.Server do
use GenServer
@gossip 10

    def start_server_node(server_tuple) do
        serverName=String.to_atom(to_string("server@")<>elem(server_tuple,0))
        {:ok,_}=Node.start(serverName)
        cookie=Application.get_env(:project1, :cookie)
        Node.set_cookie(cookie)

        numNodes=String.to_integer(to_string(Enum.at(elem(server_tuple,1),0)));
        topology=to_string(Enum.at(elem(server_tuple,1),1));
        algorithm=to_string(Enum.at(elem(server_tuple,1),2));
        
        if(topology=="2D" or topology=="imp2D") do
            numNodes=round(:math.pow(round(:math.sqrt(numNodes)),2))
        end

        list=spawn_processes(numNodes,1,[])
        #Main Process Creation
        Project2.Main.start_main_process();
        GenServer.cast(Main_process,{:update_main,list,topology})
        # Creating Agent to keep track of the active actors in the Node
        #{:ok,_} = Agent.start_link(fn -> list end, name: Agent_active_nodes)
        # Creating Agent to keep track of the active actors in the Node Ended
        creating_topology_for_each_actor(0,topology,list)

        #Start Gossip if the input is gossip
        if(algorithm=="gossip") do
            GenServer.cast(Main_process,{:random_node}) 
        end
    end

    def spawn_processes(numNodes,start_value,l) do
             if(start_value<=numNodes) do
                l=l++[start(start_value)]
                start_value=start_value+1
                l=spawn_processes(numNodes,start_value,l)
             end
             l
    end

    def creating_topology_for_each_actor(start_value,topology,list) do
            
            if(start_value<Enum.count(list)) do
                list_of_neighbours=creating_topology(start_value,topology,list)
                GenServer.cast(Enum.at(list,start_value),{:update,topology,list_of_neighbours})
                start_value=start_value+1
                creating_topology_for_each_actor(start_value,topology,list)
            end

    end

   

    def creating_topology(start_value,topology,list) do

         case topology do

            "full" -> 
                      l = get_neighbours(start_value,topology,list,0,[])
                      l

            "2D" -> l = get_neighbours(start_value,topology,list,0,[])
                    l

            "line" -> l = get_neighbours(start_value,topology,list,0,[])
                      l

            "imp2D" -> l = get_neighbours(start_value,topology,list,0,[])
                       l
         end

    end

    def get_neighbours(position,topology,list,start_value,l) do

        case topology do

            "full" -> 
            if(start_value<Enum.count(list)) do
                 if(((start_value==position)==false)) do
                    l=l++[Enum.at(list,start_value)]
                end
                start_value=start_value+1
                l=get_neighbours(position,topology,list,start_value,l)
             end

            "2D" -> 
                    n=round(:math.sqrt(Enum.count(list))) #Value of grid n*n grid
                    
                    # Forward nth Neighbour
                    if((position+n)>Enum.count(list)) do
                        #Do nothing
                    else
                        l=l++[Enum.at(list,position+n)]
                    end

                    # Backward nth Neighbour
                    if((position-n)<0) do
                        #Do nothing
                    else
                        l=l++[Enum.at(list,position-n)]
                    end

                    # Forward one Neighbour
                    if( rem((position+1),n)==0) do
                        #Do nothing
                    else
                        l=l++[Enum.at(list,position+1)]
                    end

                    # Backward one Neighbour
                    if(
                     ((position-1)<0) or 
                     ((rem((position-1),n))!=0 and (rem(position,n)==0))
                     ) do
                    #Do nothing
                    else
                        l=l++[Enum.at(list,position-1)]
                    end
                    l=List.delete(l,nil)
                    IO.puts "#{n}    #{inspect l}"

            "line" -> 
                   
                    if((position==0)==true) do
                        l=l++[Enum.at(list,position+1)]
                    else 
                    if((position==Enum.count(list)-1)==true)do
                         l=l++[Enum.at(list,position-1)]
                    else 
                        l=l++[Enum.at(list,position-1)]
                        l=l++[Enum.at(list,position+1)] 
                     end
                    end

                    l
            "imp2D" -> 

                    n=round(:math.sqrt(Enum.count(list))) #Value of grid n*n grid
                    
                    # Forward nth Neighbour
                    if((position+n)>Enum.count(list)) do
                        #Do nothing
                    else
                        l=l++[Enum.at(list,position+n)]
                    end

                    # Backward nth Neighbour
                    if((position-n)<0) do
                        #Do nothing
                    else
                        l=l++[Enum.at(list,position-n)]
                    end

                    # Forward one Neighbour
                    if( rem((position+1),n)==0) do
                        #Do nothing
                    else
                        l=l++[Enum.at(list,position+1)]
                    end

                    # Backward one Neighbour
                    if(
                     ((position-1)<0) or 
                     ((rem((position-1),n))!=0 and (rem(position,n)==0))
                     ) do
                    #Do nothing
                    else
                        l=l++[Enum.at(list,position-1)]
                    end
                    l=List.delete(l,nil)

                    # Adding a random neighbour from the remaining neighbour
                    remainList=list--l
                    l=l++[Enum.random(remainList)]
                    IO.puts "#{n}    #{inspect l}"

         end

        l
    end

   

   # Genserver processes start
   def start(start_value) do
        {:ok,pid} = GenServer.start_link(__MODULE__,:ok,name: String.to_atom(to_string(start_value)))
        pid
        #String.to_atom(to_string(start_value))
    end

    #Server Side Implementation
    def init(:ok) do
        # First is Rumor
        {:ok,%{}}
    end

    def handle_cast({:update,topology,list_of_neighbours},state) do
        #state[:topology]=topology
        #%{state | :list_of_neighbours => list_of_neighbours}
        #IO.inspect state
        #IO.inspect list_of_neighbours
        {_,state_list_neighbours}=Map.get_and_update(state,:list_of_neighbours, fn current_value -> {current_value,list_of_neighbours} end)
        {_,state_list_count}=Map.get_and_update(state,:count, fn current_value -> {current_value,0} end)
        {_,state_list_topology}=Map.get_and_update(state,:topology, fn current_value -> {current_value,topology} end)
        state=Map.merge(state,state_list_neighbours)
        state=Map.merge(state,state_list_count)
        state=Map.merge(state,state_list_topology)
        IO.puts "#{inspect self()} #{inspect state}"
        {:noreply,state}
    end

    def handle_cast({:startGossip},state) do
        IO.puts "#{inspect self()} #{state[:count]}"

        # Check if all the neigbours of this node is dead or not
        if(state[:count]>=@gossip) do
            IO.puts " Reached gossip limit #{inspect self()}"
            kill_actor(self())
        else if(Enum.count(state[:list_of_neighbours])==0) do
            {_,state_list_count}=Map.get_and_update(state,:count, fn current_value -> {current_value,current_value+@gossip} end)
             state=Map.merge(state,state_list_count) 
             GenServer.cast(self(),{:startGossip})
        else
            {_,state_list_count}=Map.get_and_update(state,:count, fn current_value -> {current_value,current_value+1} end)
            state=Map.merge(state,state_list_count)
            neighbour=Enum.random(state[:list_of_neighbours])
            IO.puts "process_id #{inspect self()} neighbour #{inspect neighbour}"
            if neighbour_is_alive(neighbour) do
                GenServer.cast(neighbour,{:startGossip})
                 #Process.sleep(1_00)
                if(state[:count]<@gossip) do
                     #Process.sleep(1_00)
                     GenServer.cast(self(),{:startGossip})
                end
            else
               #Process.sleep(1_00)
                #Remove the killed neighbour
               {_,state_list_neighbours}=Map.get_and_update(state,:list_of_neighbours, fn current_value -> {current_value,List.delete(state[:list_of_neighbours],neighbour)} end)
               state=Map.merge(state,state_list_neighbours) 
                #End
                if(state[:count]<@gossip) do
                     GenServer.cast(self(),{:startGossip})
                end
            end
             {:noreply,state}
        end
     end
        {:noreply,state}
    end
 
    def neighbour_is_alive(process_id) do
        if(Process.alive?(process_id)) do
            true
        else 
            false
        end
    end

    def kill_actor(process_id) do
         IO.puts "Killing #{inspect process_id}"
         GenServer.cast(Main_process,{:exit_process,process_id})
         #IO.inspect GenServer.call(Main_process,{:count_active_nodes})
         #count=GenServer.call(Main_process,{:count_active_nodes})   
         IO.puts "Starting new Node Gossip"     
         GenServer.cast(Main_process,{:start_gossip_alive_node})
         #IO.inspect "All Nodes are dead in. Calculate the time now"
         #Process.exit(Main_process,:normal)
    end

    # def kill_actor(process_id) do
    #     IO.puts "Killing #{inspect process_id}"
    #     list=Agent.get(Agent_active_nodes,fn state -> state end) --[process_id]
    #     Agent.update(Agent_active_nodes, fn state -> list  end) 
    #     # Check if all the nodes in the agent are dead 
    #     IO.inspect Enum.all?(Agent.get(Agent_active_nodes,fn state -> state end),fn(x) -> Process.alive?(x)==false end)
    #     if(Enum.all?(Agent.get(Agent_active_nodes,fn state -> state end),fn(x) -> Process.alive?(x)==false end)==true) do
    #         IO.inspect "All Nodes are dead"
    #         list=[];
    #         Agent.update(Agent_active_nodes,fn state ->list end)
    #         Process.exit(process_id,:normal)
    #     else
    #         aliveList=Enum.filter(Agent.get(Agent_active_nodes,fn state -> state end), fn(x) -> Process.alive?(x)==true end)--[process_id]
    #         IO.puts "process_id #{inspect process_id} alivelist #{inspect aliveList}" 
    #         random_actor=Enum.random(aliveList);
    #         IO.inspect "random #{inspect random_actor}"
    #         GenServer.cast(random_actor,{:startGossip})
    #         Process.exit(process_id,:normal)
    #         # if(Enum.count(aliveList)==1) do
    #         #       Process.exit(process_id,:normal)  
    #         #       kill_actor(Enum.at(aliveList,0))  
    #         # else
    #         #      Process.exit(process_id,:normal)
    #         # end
    #     end
        
    # end

    # def get_random_node(process_id) do    
    #      #IO.puts "I am here" 
    #      list=Agent.get(Agent_active_nodes,fn state -> state end)--[process_id]
    #      if(Enum.count(list)==0) do
    #          kill_actor(process_id)
    #      else 
    #         #Agent.update(Agent_active_nodes, fn state -> list end)
    #         random_actor=Enum.random(list);
    #         if(Process.alive?(random_actor))do
    #              GenServer.cast(random_actor,{:startGossip})  
    #              kill_actor(process_id)  
    #         else
    #             kill_actor(process_id) 
    #             get_random_node(random_actor)
    #         end
    #      end
    # end     
end