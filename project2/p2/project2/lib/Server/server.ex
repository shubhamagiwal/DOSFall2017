defmodule Project2.Server do
use GenServer
@gossip 10
@pushsumcount 3

    def start_server_node(server_tuple) do
        serverName=String.to_atom(to_string("server@")<>elem(server_tuple,0))
        {:ok,_}=Node.start(serverName)
        cookie=Application.get_env(:project1, :cookie)
        Node.set_cookie(cookie)

        numNodes=String.to_integer(to_string(Enum.at(elem(server_tuple,1),0)));
        topology=to_string(Enum.at(elem(server_tuple,1),1));
        algorithm=to_string(Enum.at(elem(server_tuple,1),2));

        if(Enum.count(elem(server_tuple,1))==4) do
            percent_to_kill=String.to_integer(to_string(Enum.at(elem(server_tuple,1),3)))/1;
        else    
            percent_to_kill=0.0
        end
        
        if(topology=="2D" or topology=="imp2D") do
            numNodes=round(:math.pow(round(:math.sqrt(numNodes)),2))
        end

        list=spawn_processes(numNodes,1,[])
        #Main Process Creation
        Project2.Main.start_main_process();
        IO.puts "....build topology"
        #:observer.start
        creating_topology_for_each_actor(0,topology,list,algorithm)
        #{_,start_mins,start_seconds}=:erlang.time()
        time_milli=:erlang.system_time(:millisecond)
        GenServer.cast(Main_process,{:update_main,list,topology,time_milli,numNodes,percent_to_kill})
        GenServer.cast(Main_process,{:kill_percent_nodes});
        #Main Process End
        IO.puts "....start protocol"
        #Start Gossip if the input is gossip
         if(algorithm=="push-sum") do
              #GenServer.cast(Main_process,{:random_node}) 
              #IO.puts "I am up"
              GenServer.cast(Main_process,{:random_node,algorithm}) 
              #IO.puts "I am down"
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

    def creating_topology_for_each_actor(start_value,topology,list,algorithm) do
            
            if(start_value<Enum.count(list)) do
                #IO.inspect [Enum.at(list,start_value)]
                if(topology=="full") do
                  list_of_neighbours=list--[Enum.at(list,start_value)]
                else
                  list_of_neighbours=creating_topology(start_value,topology,list)
                end

                #IO.inspect "List of neighbours #{inspect list_of_neighbours}"
                if(algorithm=="gossip") do
                   GenServer.cast(Enum.at(list,start_value),{:updategossip,topology,list_of_neighbours})
                else if (algorithm=="push-sum") do
                        #:updatepushsum,s,w,numberOfrounds,list_of_neighbours,topology
                        GenServer.cast(Enum.at(list,start_value),{:updatepushsum,start_value+1,1,0,list_of_neighbours,topology})
                     end
                end
                start_value=start_value+1
                creating_topology_for_each_actor(start_value,topology,list,algorithm)
            end

    end

   

    def creating_topology(start_value,topology,list) do

         case topology do

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
                   # IO.puts "#{n}    #{inspect l}"

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
                    remainList=list--l--[Enum.at(list,position)]
                    l=l++[Enum.random(remainList)]
                    #IO.puts "#{n}    #{inspect l}"
         end
         l
    end

   

   # Genserver processes start
   def start(start_value) do
        {:ok,pid} = GenServer.start_link(__MODULE__,:ok,name: String.to_atom(to_string(start_value)))
        pid
    end

    #Server Side Implementation
    def init(:ok) do
        {:ok,%{}}
    end

    def handle_cast({:removeNeighbour,neigbhbour},state) do
        new_list=state[:list_of_neighbours]--[neigbhbour]
        {_,state_is_new_list_of_neighbouts}=Map.get_and_update(state,:list_of_neighbours, fn current_value -> {current_value,new_list} end)
        state=Map.merge(state,state_is_new_list_of_neighbouts)
        {:noreply,state}
    end

   # Push Sum Algorithm 

   # Push Sum based algorithm Update

     def handle_cast({:updatepushsum,s,w,numberOfrounds,list_of_neighbours,topology},state) do
        {_,state_list_neighbours}=Map.get_and_update(state,:list_of_neighbours, fn current_value -> {current_value,list_of_neighbours} end)
        {_,state_s}=Map.get_and_update(state,:s, fn current_value -> {current_value,s} end)
        {_,state_w}=Map.get_and_update(state,:w, fn current_value -> {current_value,w} end)
        {_,state_numRounds}=Map.get_and_update(state,:numRounds, fn current_value -> {current_value,numberOfrounds} end)
        {_,state_list_topology}=Map.get_and_update(state,:topology, fn current_value -> {current_value,topology} end)
        
        #Needed for killing the node
        {_,state_current_ratio}=Map.get_and_update(state,:currentratio, fn current_value -> {current_value,s/w} end)

        state=Map.merge(state,state_list_neighbours)
        state=Map.merge(state,state_s)
        state=Map.merge(state,state_w)
        state=Map.merge(state,state_numRounds)
        state=Map.merge(state,state_list_topology)
        state=Map.merge(state,state_current_ratio)

        #IO.puts "#{inspect self()} #{inspect state}"
        {:noreply,state}

     end

     def handle_cast({:startpushsum,s,w},state) do
         #IO.inspect "I have reacher heere"
         # Get the state value of s and w
         state_s=state[:s]
         state_w=state[:w]
         state_count=state[:count]
         #Increment the present value for s and w
         state_s=state_s+s
         state_w=state_w+w
         # Difference needed for killing the node
         difference=(state_s/state_w)-state[:currentratio]
         #IO.puts "#{inspect self()} #{inspect state_s/state_w}"
         #Process.sleep(1_000)

    if (Enum.count(state[:list_of_neighbours])==0) do
             kill_actor(self(),to_string("push-sum"))
        else if(difference< :math.pow(10,-10) && state_count<@pushsumcount) do
            #Update the state values of s and w to half the value
            
            {_,state_s_new}=Map.get_and_update(state,:s, fn current_value -> {current_value,state_s/2} end)
            state=Map.merge(state,state_s_new)
            {_,state_w_new}=Map.get_and_update(state,:w, fn current_value -> {current_value,state_w/2} end)
            state=Map.merge(state,state_w_new)
            {_,state_numRounds_new}=Map.get_and_update(state,:numRounds, fn current_value -> {current_value,current_value+1} end)
            state=Map.merge(state,state_numRounds_new)
            {_,state_current_ratio}=Map.get_and_update(state,:currentratio, fn current_value -> {current_value,state_s/state_w} end)
            state=Map.merge(state,state_current_ratio)

            #Pick up a random alive neighbour and send half of s and w value
            neighbour=Enum.random(state[:list_of_neighbours])
            #IO.puts "process_id #{inspect self()} neighbour #{inspect neighbour} s #{state[:s]} w #{state[:w]}"

                if neighbour_is_alive(neighbour) do
                    GenServer.cast(neighbour,{:startpushsum,state[:s],state[:w]})
                else
                    {_,state_list_neighbours}=Map.get_and_update(state,:list_of_neighbours, fn current_value -> {current_value,List.delete(state[:list_of_neighbours],neighbour)} end)
                    state=Map.merge(state,state_list_neighbours) 
                    #Revert back the s and w value
                    {_,state_s_new}=Map.get_and_update(state,:s, fn current_value -> {current_value,current_value*2-s} end)
                    state=Map.merge(state,state_s_new)
                    {_,state_w_new}=Map.get_and_update(state,:w, fn current_value -> {current_value,current_value*2-w} end)
                    state=Map.merge(state,state_w_new)
                    {_,state_numRounds_new}=Map.get_and_update(state,:numRounds, fn current_value -> {current_value,current_value-1} end)
                    state=Map.merge(state,state_numRounds_new)
                    {_,state_current_ratio}=Map.get_and_update(state,:currentratio, fn current_value -> {current_value,(state_s-s)/(state_w-w)} end)
                    state=Map.merge(state,state_current_ratio)
                    #Call itself again to get an alive neighbour for its current s and w value
                    GenServer.cast(self(),{:startpushsum,0,0})
                end
         else if(difference < :math.pow(10,-10) && state_count>=@pushsumcount) do
              # Kill the process and choose a random node to start the pushsum again
              kill_actor(self(),to_string("push-sum"))

        else if(difference >:math.pow(10,-10)) do
                 # Update the state values of s and w to half the value 
                #IO.puts "process_id #{inspect self()} s #{state_s/2} w #{state_w/2}"
                {_,state_s_new}=Map.get_and_update(state,:s, fn current_value -> {current_value,state_s/2} end)
                state=Map.merge(state,state_s_new)
                {_,state_w_new}=Map.get_and_update(state,:w, fn current_value -> {current_value,state_w/2} end)
                state=Map.merge(state,state_w_new)
                {_,state_numRounds_new}=Map.get_and_update(state,:numRounds, fn current_value -> {current_value,0} end)
                state=Map.merge(state,state_numRounds_new)
                {_,state_current_ratio}=Map.get_and_update(state,:currentratio, fn current_value -> {current_value,state_s/state_w} end)
                state=Map.merge(state,state_current_ratio)
                #Process.sleep(1_000)
                #IO.inspect "#{inspect state}"
                # Pick up a random alive neighbour and send half of s and w value
                neighbour=Enum.random(state[:list_of_neighbours])
                #IO.puts "process_id #{inspect self()} neighbour #{inspect neighbour} s #{state[:s]/2} w #{state[:w]/2}"
                if neighbour_is_alive(neighbour) do
                    GenServer.cast(neighbour,{:startpushsum,state[:s],state[:w]})
                else
                    {_,state_list_neighbours}=Map.get_and_update(state,:list_of_neighbours, fn current_value -> {current_value,List.delete(state[:list_of_neighbours],neighbour)} end)
                    state=Map.merge(state,state_list_neighbours) 
                    #Revert back the s and w value and set the :numrounds to @pushsumcount+1 so that the node gets killed in the self call
                    {_,state_s_new}=Map.get_and_update(state,:s, fn current_value -> {current_value,current_value*2-s} end)
                    state=Map.merge(state,state_s_new)
                    {_,state_w_new}=Map.get_and_update(state,:w, fn current_value -> {current_value,current_value*2-w} end)
                    state=Map.merge(state,state_w_new)
                    {_,state_numRounds_new}=Map.get_and_update(state,:numRounds, fn current_value -> {current_value,current_value+@pushsumcount+1} end)
                    state=Map.merge(state,state_numRounds_new)
                    {_,state_current_ratio}=Map.get_and_update(state,:currentratio, fn current_value -> {current_value,(state_s-s)/(state_w-w)} end)
                    state=Map.merge(state,state_current_ratio)
                    #Call itself again to get an alive neighbour for its current s and w value
                    GenServer.cast(self(),{:startpushsum,0,0})
                end
             end
           end
        end
    end
     {:noreply,state}
end


    # Push Sum based algorithm End

     def neighbour_is_alive(process_id) do
        if(Process.alive?(process_id)) do
            true
        else 
            false
        end
    end

    def kill_actor(process_id,algorithm) do
         GenServer.cast(Main_process,{:exit_process_push_sum,process_id})  
         if(Process.whereis(Main_process)!=nil) do
            if(Process.alive?(Process.whereis(Main_process))) do 
               if(algorithm=="push-sum")do
                    GenServer.cast(Main_process,{:start_push_sum_alive_node})
                end
            end
        end  
    end
    
end