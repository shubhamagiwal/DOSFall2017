defmodule Project2.Main do
use GenServer

    def start_main_process do
        {:ok,_} = GenServer.start_link(__MODULE__,:ok,name: Main_process)
        #pid
    end 

   #Server Side Implementation
    def init(:ok) do
        # First is Rumor
        {:ok,%{}}
    end

    def handle_cast({:update_main,list,topology,start_milli},state) do
        {_,state_list}=Map.get_and_update(state,:list, fn current_value -> {current_value,list} end)
        {_,state_list_topology}=Map.get_and_update(state,:topology, fn current_value -> {current_value,topology} end)
        #{_,state_seconds}=Map.get_and_update(state,:time, fn current_value -> {current_value,seconds} end)
        {_,state_start_milli}=Map.get_and_update(state,:time_milliseconds, fn current_value -> {current_value,start_milli} end)
        #{_,state_mins}=Map.get_and_update(state,:time_mins, fn current_value -> {current_value,start_mins} end)


        state=Map.merge(state,state_list)
        state=Map.merge(state,state_list_topology)
        state=Map.merge(state,state_start_milli)
        #state=Map.merge(state,state_mins)        
        #IO.puts "#{inspect self()} #{inspect state}"
        {:noreply,state}
    end

    def handle_cast({:random_node,algorithm},state) do
        if(algorithm=="gossip") do
                GenServer.cast(Enum.random(state[:list]),{:startGossip})
        else if(algorithm=="push-sum") do
                GenServer.cast(Enum.random(state[:list]),{:startpushsum,0,0})
             end
        end   
         {:noreply,state}
    end

    def handle_call({:count_active_nodes},_from,state) do
        {:reply,Enum.count(state[:list]),state}
    end

    def handle_cast({:exit_process,process_id},state) do
            Process.exit(process_id,:normal)
            #IO.puts "#{inspect process_id} killed"
            #Process.sleep(1_00)
            {_,state_list}=Map.get_and_update(state,:list, fn current_value -> {current_value,List.delete(state[:list],process_id)} end)
            state=Map.merge(state,state_list) 
            # if(Enum.count(state[:list])==1) do
            #     Process.exit(Enum.at(state[:list],0),:normal)
            #     {_,state_list}=Map.get_and_update(state,:list, fn current_value -> {current_value,List.delete(state[:list],Enum.at(state[:list],0))} end)
            #     state=Map.merge(state,state_list) 
            # end
            {:noreply,state}
    end

    def handle_cast({:kill_main},state) do
        end_time_milli=:erlang.system_time(:millisecond)
        start_time_milli=state[:time_milliseconds]
        time=end_time_milli-start_time_milli
        IO.puts "Time the program ran for is #{time} milliseconds"
        # IO.inspect "Start Mins #{state[:time_mins]}"
        # IO.inspect "Start Seconds #{state[:time_seconds]}"
        # IO.puts "End minutes #{fmins}"
        # IO.puts "End seconds #{fsecs}"        
        # if(state[:time_mins]==fmins) do
        #     IO.puts "Time the program ran for is #{fsecs-state[:time_seconds]} seconds"
        # else if(state[:time_mins]>fmins) do
        #     runtime=(3600-state[:time_mins]*60-state[:time_seconds])+fmins*60+fsecs
        #     IO.puts "Time the program ran for is #{runtime} seconds"
        # else 
        #     runtime=(fmins*60+fsecs)-(state[:time_mins]*60+state[:time_seconds])
        #     IO.puts "Time the program ran for is #{runtime} seconds"
        # end
        # end
        Process.exit(self(),:normal)
        {:noreply,state}
    end

    def handle_cast({:start_gossip_alive_node},state) do
        #Process.sleep(1_0)
        if(Enum.count(state[:list])==0) do
            #IO.inspect "All Nodes are dead in. Calculate the time now"
            GenServer.cast(self(),{:kill_main})
            {:noreply,state}
        else 
            #IO.inspect "state list = #{inspect state[:list]}"
            alive_neighbour=Enum.random(state[:list])
            #IO.inspect "alive neighbour=#{inspect alive_neighbour}"
            if(Process.alive?(alive_neighbour)) do
                GenServer.cast(alive_neighbour,{:startGossip})
                {:noreply,state}
            else
                IO.puts " I am here"
                GenServer.cast(Main_process,{:exit_process,alive_neighbour})
                GenServer.cast(Main_process,{:start_gossip_alive_node})
                {:noreply,state}
            end
        end
    end


    def handle_cast({:start_push_sum_alive_node},state) do
        #Process.sleep(1_0)
        if(Enum.count(state[:list])==0) do
            #IO.inspect "All Nodes are dead in. Calculate the time now"
            GenServer.cast(self(),{:kill_main})
            {:noreply,state}
        else 
            alive_neighbour=Enum.random(state[:list])
            if(Process.alive?(alive_neighbour)) do
                GenServer.cast(alive_neighbour,{:startpushsum,0,0})
                {:noreply,state}
            else
                #IO.puts " I am here"
                GenServer.cast(Main_process,{:exit_process,alive_neighbour})
                GenServer.cast(Main_process,{:start_push_sum_alive_node})
                {:noreply,state}
            end
        end
    end

end