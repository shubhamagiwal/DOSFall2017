defmodule Project2.Main do
use GenServer
@network_convergence_percent 0.9

    def start_main_process() do
        {:ok,_} = GenServer.start_link(__MODULE__,:ok,name: Main_process)
        #pid
    end 

   #Server Side Implementation
    def init(:ok) do
        {:ok,%{}}
    end

    def handle_cast({:update_main,list,topology,start_milli,convergence,killing_mechanism,percentage_nodes_killing,algorithm},state) do
       {_,state_list}=Map.get_and_update(state,:list, fn current_value -> {current_value,list} end)
        {_,state_list_topology}=Map.get_and_update(state,:topology, fn current_value -> {current_value,topology} end)
        {_,state_start_milli}=Map.get_and_update(state,:time_milliseconds, fn current_value -> {current_value,start_milli} end)
        {_,state_convergence}=Map.get_and_update(state,:convergence, fn current_value -> {current_value,convergence} end)
       

        state=Map.merge(state,state_list)
        state=Map.merge(state,state_list_topology)
        state=Map.merge(state,state_start_milli)
        state=Map.merge(state,state_convergence)


         #List of Alive node to dead nodes
        {_,state_alive_nodes}=Map.get_and_update(state,:alive_nodes, fn current_value -> {current_value,Enum.count(state[:list])} end)
        state=Map.merge(state,state_alive_nodes)
        {_,state_dead_nodes}=Map.get_and_update(state,:dead_nodes, fn current_value -> {current_value,0} end)
        state=Map.merge(state,state_dead_nodes)
        #Needed for max convergence attempts
        {_,max_count_convergence}=Map.get_and_update(state,:count, fn current_value -> {current_value,0} end)
        state=Map.merge(state,max_count_convergence)
        #Update the killing mechanism and Percentage
         {_,state_killing_mechanism}=Map.get_and_update(state,:killing_mechanism, fn current_value -> {current_value,killing_mechanism} end)
        state=Map.merge(state,state_killing_mechanism)

         {_,state_percentage_nodes_killing}=Map.get_and_update(state,:percentage_node_kill, fn current_value -> {current_value,percentage_nodes_killing} end)
        state=Map.merge(state,state_percentage_nodes_killing)

        {_,state_algorithm}=Map.get_and_update(state,:algorithm, fn current_value -> {current_value,algorithm} end)
        state=Map.merge(state,state_algorithm)

        {_,state_nodes_to_kill}=Map.get_and_update(state,:number_nodes_to_kill, fn current_value -> {current_value,round((Enum.count(state[:list])*state[:percentage_node_kill])/100)} end)
        state=Map.merge(state,state_nodes_to_kill)


         #List of Alive node to dead nodes
        {_,state_alive_nodes}=Map.get_and_update(state,:alive_nodes, fn current_value -> {current_value,Enum.count(state[:list])} end)
        state=Map.merge(state,state_alive_nodes)
        {_,state_dead_nodes}=Map.get_and_update(state,:dead_nodes, fn current_value -> {current_value,0} end)
        state=Map.merge(state,state_dead_nodes)
        #Number of nodes in the present list
         {_,max_count_list}=Map.get_and_update(state,:count_list, fn current_value -> {current_value,Enum.count(list)} end)
        state=Map.merge(state,max_count_list)

        {:noreply,state}
    end

    def handle_cast({:killing_process},state) do
        #IO.puts "#{inspect state[:algorithm]} #{inspect state[:killing_mechanism]}"
        if(state[:killing_mechanism]=="begin_kill" and state[:algorithm]=="push-sum") do
            #IO.puts " iam in before fill"
            to_kill_nodes=round((Enum.count(state[:list])*state[:percentage_node_kill])/100)
            {_,state_dead_nodes}=Map.get_and_update(state,:dead_nodes, fn current_value -> {current_value,to_kill_nodes} end)
            state=Map.merge(state,state_dead_nodes)
            start_kill_timer=:erlang.system_time(:millisecond)
            updated_list=kill_nodes_push_sum(to_kill_nodes,state[:list])
            end_kill_timer=:erlang.system_time(:millisecond)
            total_time_for_killing=end_kill_timer-start_kill_timer
            {_,state_list}=Map.get_and_update(state,:list, fn current_value -> {current_value,updated_list} end)
            state=Map.merge(state,state_list)
             {_,state_list}=Map.get_and_update(state,:time_milliseconds, fn current_value -> {current_value,current_value+total_time_for_killing} end)
            state=Map.merge(state,state_list)
            if(state[:percentage_node_kill]>=100.0) do
                kill_main_process(:erlang.system_time(:millisecond))
            end
        else if(state[:killing_mechanism]=="begin_kill" and state[:algorithm]=="gossip") do
                to_kill_nodes=round((Enum.count(state[:list])*state[:percentage_node_kill])/100)
                {_,state_dead_nodes}=Map.get_and_update(state,:dead_nodes, fn current_value -> {current_value,to_kill_nodes} end)
                state=Map.merge(state,state_dead_nodes)
                start_kill_timer=:erlang.system_time(:millisecond)
                updated_list=kill_nodes_gossip(to_kill_nodes,state[:list])
                end_kill_timer=:erlang.system_time(:millisecond)
                total_time_for_killing=end_kill_timer-start_kill_timer
                {_,state_list}=Map.get_and_update(state,:list, fn current_value -> {current_value,updated_list} end)
                state=Map.merge(state,state_list)
                {_,state_list}=Map.get_and_update(state,:time_milliseconds, fn current_value -> {current_value,current_value+total_time_for_killing} end)
                state=Map.merge(state,state_list)

                  if(state[:percentage_node_kill]>=100.0) do
                    kill_main_process(:erlang.system_time(:millisecond))
                 end
             end
        end

        {:noreply,state}
    end

    def kill_nodes_gossip(to_kill_nodes,list) do
         if(to_kill_nodes>0) do
              random_node_kill=Enum.random(list)
              list=list--[random_node_kill]
              GenServer.cast(random_node_kill,{:update_alive_status_gossip})
              list=kill_nodes_push_sum(to_kill_nodes-1,list)
        end
        list
    end

    def kill_nodes_push_sum(to_kill_nodes,list) do
        if(to_kill_nodes>0) do
              random_node_kill=Enum.random(list)
              list=list--[random_node_kill]
              Process.exit(random_node_kill,:normal)
              list=kill_nodes_push_sum(to_kill_nodes-1,list)
        end
        list
    end

    def handle_cast({:random_node,algorithm},state) do
        if(algorithm=="gossip") do
                GenServer.cast(Enum.random(state[:list]),{:startGossip,false})
        else if(algorithm=="push-sum") do
                GenServer.cast(Enum.random(state[:list]),{:startpushsum,0,0})
             end
        end   
         {:noreply,state}
    end

    def handle_info({:get_ratio},state)do
        if((state[:dead_nodes]/state[:count_list])<0.5)do
            kill_main_process_no_network_converge() 
        else
            kill_main_process(state[:time_milliseconds]) 
        end   
         {:noreply, state}
    end

    def kill_main_process_no_network_converge()do
        IO.puts "The given network will not converge." 
        Process.exit(self(),:normal)
    end

    def handle_cast({:exit_process,process_id,is_alive_node},state) do
            IO.puts "#{inspect process_id} killing  list of neighbours left#{inspect state[:list]} count #{ inspect state[:dead_nodes]}"
            Process.send_after(self(), {:get_ratio}, 1_0000)
            if(is_alive_node) do
               
                old_list=state[:list];
                new_list=state[:list]--[process_id]

                if(Enum.count(new_list)>0 
                   and state[:killing_mechanism]=="after_kill" 
                   and state[:algorithm]=="gossip"
                   and state[:number_nodes_to_kill]>0 
                   and Enum.count(old_list)!=Enum.count(new_list) ) do
                   kill_random_neighbour=Enum.random(new_list);
                   GenServer.cast(kill_random_neighbour,{:update_alive_status_gossip})
                   new_list=new_list--[kill_random_neighbour]
                   {_,update_number_nodes_to_kill}=Map.get_and_update(state,:number_nodes_to_kill, fn current_value -> {current_value,current_value-1} end)
                    state=Map.merge(state,update_number_nodes_to_kill)
                end
                #IO.puts "old_list #{inspect old_list} new_list #{inspect new_list}"
                #IO.puts "Killing #{inspect process_id} -> Status of the node #{inspect is_alive_node} alive #{inspect state[:alive_nodes]} dead#{inspect state[:dead_nodes]} old_list_new_list_equal=#{inspect old_list==new_list}"
                if(Enum.count(old_list)==Enum.count(new_list)) do
                    {_,max_count_convergence}=Map.get_and_update(state,:count, fn current_value -> {current_value,current_value+1} end)
                    state=Map.merge(state,max_count_convergence)
                    if(state[:count]>state[:convergence]) do
                        #kill_main_process(state[:time_milliseconds])
                    else
                               if(Enum.count(new_list)>0) do
                                    #GenServer.cast(Enum.random(new_list),{:startGossip,false})
                               else
                                    kill_main_process(state[:time_milliseconds])
                               end
                          
                          #IO.puts "#{inspect state[:count]}"
                    end

                 else 
                    {_,list_new}=Map.get_and_update(state,:list, fn current_value -> {current_value,new_list} end)
                    state=Map.merge(state,list_new)
                    {_,max_count_convergence}=Map.get_and_update(state,:count, fn current_value -> {current_value,0} end)
                    state=Map.merge(state,max_count_convergence)
                    {_,state_alive_nodes}=Map.get_and_update(state,:alive_nodes, fn current_value -> {current_value,current_value-1} end)
                    state=Map.merge(state,state_alive_nodes)
                    {_,state_dead_nodes}=Map.get_and_update(state,:dead_nodes, fn current_value -> {current_value,current_value+1} end)
                    state=Map.merge(state,state_dead_nodes)
                    #IO.puts "Ration #{inspect (state[:dead_nodes]/state[:count_list])}"
                    #IO.puts "process_id #{inspect process_id}AliveNodes: #{inspect state[:alive_nodes]}"

                               if((state[:dead_nodes]/state[:count_list])>=@network_convergence_percent)do
                                    kill_main_process(state[:time_milliseconds])     
                               else if(Enum.count(new_list)>0) do
                                    #GenServer.cast(Enum.random(new_list),{:startGossip,false})
                               else if(Enum.count(new_list)==0) do
                                    kill_main_process(state[:time_milliseconds])
                                   end
                               end
                            end
                    end    
            end
             {:noreply,state}
        end

    def kill_main_process(time)do
        end_time_milli=:erlang.system_time(:millisecond)
        start_time_milli=time
        time=end_time_milli-start_time_milli
        IO.puts "Time the program ran for is #{time} milliseconds"
        Process.exit(self(),:normal)
    end


    def handle_cast({:start_push_sum_alive_node},state) do
        if(Enum.count(state[:list])==0) do
            #IO.inspect "All Nodes are dead in. Calculate the time now"
            kill_main_process(state[:time_milliseconds])
        else 
            alive_neighbour=Enum.random(state[:list])
            if(Process.alive?(alive_neighbour)) do
                GenServer.cast(alive_neighbour,{:startpushsum,0,0})
            else
                #IO.puts " I am here"
                GenServer.cast(Main_process,{:exit_process_push_sum,alive_neighbour})
                GenServer.cast(Main_process,{:start_push_sum_alive_node})
            end
        end
         {:noreply,state}
    end

    def handle_cast({:exit_process_push_sum,process_id},state) do
            Process.exit(process_id,:normal)

            if(Enum.count(state[:list])>0 
                   and state[:killing_mechanism]=="after_kill" 
                   and state[:algorithm]=="push-sum"
                   and state[:number_nodes_to_kill]>0 ) do
                   kill_random_neighbour=Enum.random(state[:list]);
                   Process.exit(kill_random_neighbour,:normal)
                   {_,update_number_nodes_to_kill}=Map.get_and_update(state,:number_nodes_to_kill, fn current_value -> {current_value,current_value-1} end)
                   state=Map.merge(state,update_number_nodes_to_kill)
                   {_,state_list}=Map.get_and_update(state,:list, fn current_value -> {current_value,List.delete(state[:list],kill_random_neighbour)} end)
                   state=Map.merge(state,state_list) 
                   {_,state_dead_nodes}=Map.get_and_update(state,:dead_nodes, fn current_value -> {current_value,current_value-2} end)
                   state=Map.merge(state,state_dead_nodes)
                    if(Enum.count(state[:list])<=0) do
                        kill_main_process(state[:time_milliseconds])
                    end
            else
                Process.send_after(self(), {:get_ratio}, 1_0000)
                IO.puts "#{inspect process_id} #{ inspect state[:list]}"
                {_,state_dead_nodes}=Map.get_and_update(state,:dead_nodes, fn current_value -> {current_value,current_value+1} end)
                state=Map.merge(state,state_dead_nodes)
                {_,state_list}=Map.get_and_update(state,:list, fn current_value -> {current_value,List.delete(state[:list],process_id)} end)
                state=Map.merge(state,state_list) 
                {_,state_alive_nodes}=Map.get_and_update(state,:alive_nodes, fn current_value -> {current_value,current_value-1} end)
                state=Map.merge(state,state_alive_nodes)

                if((state[:dead_nodes]/state[:count_list])>=@network_convergence_percent)do
                       kill_main_process(state[:time_milliseconds])     
                else if(Enum.count(state[:list])>0) do
                                    #GenServer.cast(Enum.random(new_list),{:startGossip,false})
                else if(Enum.count(state[:list])==0) do
                        kill_main_process(state[:time_milliseconds])
                    end
                 end
                end
            end
            {:noreply,state}
    end

    def handle_call({:count_active_nodes},_from,state) do
        {:reply,Enum.count(state[:list]),state}
    end

end