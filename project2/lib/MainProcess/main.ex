defmodule Project2.Main do
use GenServer
@maxconvergence 10

    def start_main_process() do
        {:ok,_} = GenServer.start_link(__MODULE__,:ok,name: Main_process)
        #pid
    end 

   #Server Side Implementation
    def init(:ok) do
        {:ok,%{}}
    end

    def handle_cast({:update_main,list,topology,start_milli,convergence},state) do
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
        #Number of nodes in the present list
         {_,max_count_list}=Map.get_and_update(state,:count_list, fn current_value -> {current_value,Enum.count(list)} end)
        state=Map.merge(state,max_count_list)
        IO.puts "AliveNodes: #{inspect state[:alive_nodes]} Count #{inspect Enum.count(state[:list])}"
                IO.puts " list #{inspect (state[:list])}"

        {:noreply,state}
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
            IO.puts "#{inspect process_id} killing  list of neighbours left#{inspect state[:list]}"
            Process.send_after(self(), {:get_ratio}, 1_0000)
            if(is_alive_node) do
               
                old_list=state[:list];
                new_list=state[:list]--[process_id]
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
                    IO.puts "Ration #{inspect (state[:dead_nodes]/state[:count_list])}"
                    IO.puts "AliveNodes: #{inspect state[:alive_nodes]}"

                               if((state[:dead_nodes]/state[:count_list])>=0.5)do
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
        #IO.puts "After Gen near kill"
        #IO.puts "I am here"
        end_time_milli=:erlang.system_time(:millisecond)
        start_time_milli=time
        time=end_time_milli-start_time_milli
        IO.puts "Time the program ran for is #{time} milliseconds"
        Process.exit(self(),:normal)
    end


    def handle_cast({:start_push_sum_alive_node},state) do
        #Process.sleep(1_0)
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
            {_,state_list}=Map.get_and_update(state,:list, fn current_value -> {current_value,List.delete(state[:list],process_id)} end)
            state=Map.merge(state,state_list) 
            {:noreply,state}
    end

    def handle_call({:count_active_nodes},_from,state) do
        {:reply,Enum.count(state[:list]),state}
    end

end