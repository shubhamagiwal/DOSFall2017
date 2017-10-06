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

    def handle_cast({:kill_percent_nodes},state) do
        num_nodes=state[:convergence]

        if(state[:percent_kill]>10.0 and state[:percent_kill]<=100.0 ) do
            to_kill_nodes=round(num_nodes*state[:percent_kill]/100)
            start_kill_timer=:erlang.system_time(:millisecond)
            list=kill_nodes(to_kill_nodes,state[:list])
            end_kill_timer=:erlang.system_time(:millisecond)
            total_time_for_killing=end_kill_timer-start_kill_timer
            {_,state_list}=Map.get_and_update(state,:list, fn current_value -> {current_value,list} end)
            state=Map.merge(state,state_list)
            {_,state_list}=Map.get_and_update(state,:time_milliseconds, fn current_value -> {current_value,current_value+total_time_for_killing} end)
            state=Map.merge(state,state_list)
        else
            #DO Nothing
        end

        if(state[:percent_kill]==100.0) do
            kill_main_process(state[:time_milliseconds])
        end

        {:noreply,state}
    end

    def kill_nodes(to_kill_nodes,list) do
        if(to_kill_nodes>0) do
              random_node_kill=Enum.random(list)
              list=list--[random_node_kill]
              Process.exit(random_node_kill,:normal)
              list=kill_nodes(to_kill_nodes-1,list)
        end
        list
    end

    def handle_cast({:update_main,list,topology,start_milli,convergence,percent_to_kill},state) do
        {_,state_list}=Map.get_and_update(state,:list, fn current_value -> {current_value,list} end)
        {_,state_list_topology}=Map.get_and_update(state,:topology, fn current_value -> {current_value,topology} end)
        {_,state_start_milli}=Map.get_and_update(state,:time_milliseconds, fn current_value -> {current_value,start_milli} end)
        {_,state_convergence}=Map.get_and_update(state,:convergence, fn current_value -> {current_value,convergence} end)
        {_,state_percent_to_kill}=Map.get_and_update(state,:percent_kill, fn current_value -> {current_value,percent_to_kill} end)


        state=Map.merge(state,state_list)
        state=Map.merge(state,state_list_topology)
        state=Map.merge(state,state_start_milli)
        state=Map.merge(state,state_convergence)
        state=Map.merge(state,state_percent_to_kill)
        {_,max_count_convergence}=Map.get_and_update(state,:count, fn current_value -> {current_value,0} end)
        state=Map.merge(state,max_count_convergence)

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

end