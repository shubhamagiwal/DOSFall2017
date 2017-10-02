defmodule Project2.Main do
use GenServer

    def start_main_process do
        {:ok,_} = GenServer.start_link(__MODULE__,:ok,name: Main_process)
    end 

   #Server Side Implementation
    def init(:ok) do
        # First is Rumor
        {:ok,%{}}
    end

    def handle_cast({:update_main,list,topology},state) do
        {_,state_list}=Map.get_and_update(state,:list, fn current_value -> {current_value,list} end)
        {_,state_list_topology}=Map.get_and_update(state,:topology, fn current_value -> {current_value,topology} end)
        state=Map.merge(state,state_list)
        state=Map.merge(state,state_list_topology)
        #IO.puts "#{inspect self()} #{inspect state}"
        {:noreply,state}
    end

    def handle_cast({:random_node},state) do
        GenServer.cast(Enum.random(state[:list]),{:startGossip})
         {:noreply,state}
    end

    def handle_call({:count_active_nodes},_from,state) do
        {:reply,Enum.count(state[:list]),state}
    end

    def handle_cast({:exit_process,process_id},state) do
            Process.exit(process_id,:normal)
            IO.puts "#{inspect process_id} killed"
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
        IO.inspect "All Nodes are dead in. Calculate the time now"
        IO.inspect "awersome"
        Process.exit(self(),:normal)
        {:noreply,state}
    end

    def handle_cast({:start_gossip_alive_node},state) do
        if(Enum.count(state[:list])==0) do
           # IO.inspect "All Nodes are dead in. Calculate the time now"
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

end