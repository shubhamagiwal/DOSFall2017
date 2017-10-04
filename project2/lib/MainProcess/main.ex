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

    def handle_cast({:exit_process,process_id,is_alive_node},state) do
            #IO.inspect process_id
            if(is_alive_node && state[:alive_nodes]>0) do
               
                old_list=state[:list];
                new_list=state[:list]--[process_id]
                #IO.puts "old_list #{inspect old_list} new_list #{inspect new_list}"
                #IO.puts "Killing #{inspect process_id} -> Status of the node #{inspect is_alive_node} alive #{inspect state[:alive_nodes]} dead#{inspect state[:dead_nodes]} old_list_new_list_equal=#{inspect old_list==new_list}"
                if(Enum.count(old_list)==Enum.count(new_list)) do
                    {_,max_count_convergence}=Map.get_and_update(state,:count, fn current_value -> {current_value,current_value+1} end)
                    state=Map.merge(state,max_count_convergence)
                    #IO.puts "old_list #{inspect old_list} new_list #{inspect new_list}"
                    if(state[:count]>state[:convergence]) do
                        kill_main_process(state[:time_milliseconds])
                    else
                          if(state[:topology]=="line") do
                               if(Enum.count(new_list)>0) do
                                    GenServer.cast(Enum.random(new_list),{:startGossip,false})
                               else
                                    kill_main_process(state[:time_milliseconds])
                               end
                          end
                          #IO.puts "#{inspect state[:count]}"
                    #Do nothing 
                    end

                 else 
                    {_,list_new}=Map.get_and_update(state,:list, fn current_value -> {current_value,new_list} end)
                    state=Map.merge(state,list_new)
                    {_,max_count_convergence}=Map.get_and_update(state,:count, fn current_value -> {current_value,0} end)
                    state=Map.merge(state,max_count_convergence)

                    if(state[:topology]=="line") do
                             if(Enum.count(new_list)>0) do
                                    GenServer.cast(Enum.random(new_list),{:startGossip,false})
                               else
                                    kill_main_process(state[:time_milliseconds])
                               end
                    end

                 end
            end
             {:noreply,state}
        end

            #     {_,state_alive_nodes}=Map.get_and_update(state,:alive_nodes, fn current_value -> {current_value,current_value-1} end)
            #     state=Map.merge(state,state_alive_nodes)
            #     {_,state_dead_nodes}=Map.get_and_update(state,:dead_nodes, fn current_value -> {current_value,current_value+1} end)
            #     state=Map.merge(state,state_dead_nodes)
            #     #IO.puts "Killing #{inspect process_id}"
            #     IO.puts "alive #{inspect state[:alive_nodes]} dead#{inspect state[:dead_nodes]}"
            #     #IO.puts ""
            #     if(state[:dead_nodes]==1) do
            #         {_,state_list}=Map.get_and_update(state,:list, fn current_value -> {current_value,List.delete(state[:list],process_id)} end)
            #         state=Map.merge(state,state_list) 
            #         #{:noreply,state}
            #     else if(state[:alive_nodes]==1) do
            #          GenServer.cast(self(),{:kill_main})
            #     else if(
            #             ((state[:alive_nodes]+1)/(state[:dead_nodes]-1))>((state[:alive_nodes])/(state[:dead_nodes]))
            #             and state[:alive_nodes]>0
            #           ) do
            #              {_,state_list}=Map.get_and_update(state,:list, fn current_value -> {current_value,List.delete(state[:list],process_id)} end)
            #              state=Map.merge(state,state_list) 
            #              #IO.inspect state
            #              {_,max_count_convergence}=Map.get_and_update(state,:count, fn current_value -> {current_value,0} end)
            #              state=Map.merge(state,max_count_convergence) 
            #              #{:noreply,state}                     
            #     else if(state[:count]<@maxconvergence and state[:alive_nodes]>0) do
            #          #IO.puts "state count #{state[:count]} maxconvergence #{@maxconvergence}"
            #          {_,max_count_convergence}=Map.get_and_update(state,:count, fn current_value -> {current_value,current_value+1} end)
            #          state=Map.merge(state,max_count_convergence)
            #          #{:noreply,state}
            #         end
            #        end
            #     end
            #  end

            # else
            #     #IO.puts "#{inspect process_id} that is killing the main node"
            #     GenServer.cast(self(),{:kill_main})
            #     #{:noreply,state}
            # end

    def kill_main_process(time)do
        #IO.puts "After Gen near kill"
        #IO.puts "I am here"
        end_time_milli=:erlang.system_time(:millisecond)
        start_time_milli=time
        time=end_time_milli-start_time_milli
        IO.puts "Time the program ran for is #{time} milliseconds"
        Process.exit(self(),:normal)
    end

    # def handle_cast(:kill_main,state) do
    #     IO.puts "I am here"
    #     end_time_milli=:erlang.system_time(:millisecond)
    #     start_time_milli=state[:time_milliseconds]
    #     time=end_time_milli-start_time_milli
    #     IO.puts "Time the program ran for is #{time} milliseconds"

    #     Process.exit(self(),:normal)
    #     {:noreply,state}
    # end

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