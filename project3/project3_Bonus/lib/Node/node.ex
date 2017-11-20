defmodule Project3.Node do
use GenServer
    
    #Generate Node process
    def start(random_node_id,b) do
        hash=:crypto.hash(:sha, to_string(random_node_id)) |> Base.encode16 |> Convertat.from_base(16) |> Convertat.to_base(b+1)
        #hash=String.slice(hash,0..@nodeLength)
        #IO.puts "#{inspect random_node_id} - #{inspect hash} - #{inspect self()}"
        {:ok,pid} = GenServer.start_link(__MODULE__,hash)
        {pid,hash,random_node_id}
    end

    #Server Side Implementation
    def init(args) do  
        {:ok,%{:node_id => args}}
    end

    #update the larger leaf set , smaller leaf set

    def handle_cast({:updateLeafSet,larger_leaf_set,smaller_leaf_set,neighbor_set,routing_table,num_request,numberRows,numberColumns},state) do
        {_,state_larger_leaf_set}=Map.get_and_update(state,:larger_leaf_set, fn current_value -> {current_value,larger_leaf_set} end)
        {_,state_smaller_leaf_set}=Map.get_and_update(state,:smaller_leaf_set, fn current_value -> {current_value,smaller_leaf_set} end)
        {_,state_neighbor_set}=Map.get_and_update(state,:neighbor_set, fn current_value -> {current_value,neighbor_set} end)
        {_,state_routing_table}=Map.get_and_update(state,:routing_table, fn current_value -> {current_value,routing_table} end)
        {_,state_num_request}=Map.get_and_update(state,:num_request, fn current_value -> {current_value,num_request} end)
        {_,state_hop_count}=Map.get_and_update(state,:hop_count, fn current_value -> {current_value,0} end)
        {_,state_number_rows}=Map.get_and_update(state,:number_rows, fn current_value -> {current_value,numberRows} end)
        {_,state_number_columns}=Map.get_and_update(state,:number_columns, fn current_value -> {current_value,numberColumns} end)


        state=Map.merge(state,state_larger_leaf_set)
        state=Map.merge(state,state_smaller_leaf_set)
        state=Map.merge(state, state_neighbor_set)
        state=Map.merge(state, state_routing_table)
        state=Map.merge(state, state_num_request)
        state=Map.merge(state, state_hop_count)
        state=Map.merge(state, state_number_rows)
        state=Map.merge(state, state_number_columns)

        #IO.puts "#{inspect self()} #{inspect state}"

        {:noreply,state}
    end

    def handle_cast({:receive_request_to_cast,nodeId,count,node_list_count,process_id,hash,b,killed_nodes,alive_nodes,list_nodes_pid},state) do
        if(count<state[:num_request]) do
        #Generate Key and cast again with count incremented
        #Generated the random key and cast
        #random_number = to_string(:rand.uniform(node_list_count))

        key=:crypto.hash(:sha,Project3.LibFunctions.randomizer(128,true))|> Base.encode16 |> Convertat.from_base(16) |> Convertat.to_base(b+1)
        #IO.puts "#{inspect self()} is #{count} has key #{inspect key}"
        #key=String.slice(key,0..@nodeLength)
        #IO.puts "#{key} is the the key and #{hash} is the hash"
        GenServer.cast(self(),{:route,key,hash,b,0,killed_nodes,alive_nodes,list_nodes_pid})
        #Generated the random key and cast ended 

        #Recast to itself
        #Process.sleep(1_000)
        #IO.puts "key = #{key} send for #{inspect self()}"
        GenServer.cast(self(),{:receive_request_to_cast,nodeId,count,node_list_count,process_id,hash,b,killed_nodes,alive_nodes,list_nodes_pid})
        #Recast to itself done
        end
        {:noreply,state}

    end

    def handle_cast({:updateleafset,larger_leaf_set,smaller_leaf_set},state) do
        {_,state_larger_leaf_set}=Map.get_and_update(state,:larger_leaf_set, fn current_value -> {current_value,larger_leaf_set} end)
        state=Map.merge(state,state_larger_leaf_set)
        {_,state_smaller_leaf_set}=Map.get_and_update(state,:smaller_leaf_set, fn current_value -> {current_value,smaller_leaf_set} end)
        state=Map.merge(state,state_smaller_leaf_set)
        {:noreply,state}
    end

    def handle_cast({:updateneighbourset,neigbhour_set},state) do
        {_,state_neighbor_set}=Map.get_and_update(state,:neighbor_set, fn current_value -> {current_value,neigbhour_set} end)
        state=Map.merge(state, state_neighbor_set)
        {:noreply,state}
    end

    def handle_cast({:updateroutingtable,routing_table},state) do
        {_,state_neighbor_set}=Map.get_and_update(state,:routing_table, fn current_value -> {current_value,routing_table} end)
        state=Map.merge(state, state_neighbor_set)
        {:noreply,state}
    end

    def handle_cast({:sendHopCountDirect,b},state) do

            dummy_call_to_boss(0,state[:num_request],b)
        
        {:noreply,state}
    end

    def dummy_call_to_boss(index,numRequest,b) do
            if(index<numRequest)do
                        GenServer.cast(Boss_Server,{:delivered,0,self(),:crypto.hash(:sha,Project3.LibFunctions.randomizer(128,true))|> Base.encode16 |> Convertat.from_base(16) |> Convertat.to_base(b+1)})
                        dummy_call_to_boss(index+1,numRequest,b)
            end
    end

    def handle_cast({:route,key,hashOfNode,b,hops,killed_nodes,alive_nodes,list_nodes_pid},state) do
        #Combine the leafsets small and big with sorting
        #Update the leafsets with new enteries
       
        leafsets=state[:larger_leaf_set]++state[:smaller_leaf_set]
        length_1=length(leafsets--alive_nodes)
        length_2=length(state[:neighbor_set]--alive_nodes)
        #IO.puts "value #{inspect length_1} "
        #GEt new random leafs
       
            if(length_1>0) do
                #IO.puts "Old Leafset "
                leafsets=get_new_Leafs(leafsets,killed_nodes,alive_nodes,list_nodes_pid)
                #IO.inspect leafsets
                if(length(leafsets)>0) do
                    chunks=Enum.chunk(leafsets,round(length(leafsets)/2), round(length(leafsets)/2), [])
                    GenServer.cast(self(),{:updateleafset,Enum.at(chunks,0),Enum.at(chunks,1)})
                else
                    chunks=leafsets
                    GenServer.cast(self(),{:updateleafset,chunks,[]})
                end
            end

            if(length_2>0) do
                neighbor_set=get_new_neighbourhoodSet(state[:neighbor_set],killed_nodes,alive_nodes,list_nodes_pid)
                GenServer.cast(self(),{:updateneighbourset,neighbor_set})
            end

            routing_table=update_routing_table(state[:routing_table],0,0,state[:number_rows],state[:number_columns],killed_nodes,alive_nodes,list_nodes_pid,%{})
            #IO.puts "#{inspect routing_table} "
            GenServer.cast(self(),{:updateroutingtable,routing_table})

        #Remove the deadnodes if any Done
        leafsets=Enum.sort(leafsets,fn(x,y) -> elem(x,1)<elem(y,1)  end)
        #Update the small and larger leaf set
        lowersLeafSetValue=elem(Enum.at(leafsets,0),1)
        higherLeafSetValue=elem(Enum.at(leafsets,length(leafsets)-1),1)
        #Remove the deadnodes and 

             
        if(key>=lowersLeafSetValue and key<=higherLeafSetValue) do
            # Value is in the neighbourhood set
            GenServer.cast(Boss_Server,{:delivered,hops+1,self(),key})
        else
            #Find the longest matching prefix which the key and hashNode
            #IO.puts "I am in other the neigbhourser #{inspect self()}"
            row=longest_prefix_matched(key,hashOfNode,0,0)
            if(state[:number_rows]<= row) do
                #    def nearest_neighbour(key,row,columnIndex,longest_prefix_count) do
                nearest_neighbour=nearest_neighbour(key,state[:routing_table][state[:number_rows]-1],0,row,state[:number_columns])
            else
                nearest_neighbour=nearest_neighbour(key,state[:routing_table][row],0,row,state[:number_columns])
            end

            #IO.inspect nearest_neighbour

            if(elem(nearest_neighbour,2)==-1) do
                # No Nearest longest+1 prefix match found
                # Combine Leaf small set,right set and routing table set
                combineSet=leafsets++get_routing_table_row(state[:routing_table],state[:number_rows],state[:number_columns],[],0,0)++state[:neighbor_set]
                #IO.inspect combineSet
                nearest_node=no_nearest_longestplus1_prefix_node(combineSet,key,hashOfNode,row)
                #IO.puts "Nearest node for key #{inspect key} is #{inspect nearest_node} "
                if(elem(nearest_node,2)==-1) do
                    #Do not cast this is the nearest neigbhour
                    #IO.puts "Delivered"
                    #IO.puts "Delivered #{key} not found"
                    GenServer.cast(Boss_Server,{:delivered,hops,self(),key})
                else
                    #Cast to the given nearest neighbour
                    #IO.inspect "Casting"
                    GenServer.cast(elem(nearest_node,0),{:route,key,elem(nearest_node,1),b,hops+1,killed_nodes,alive_nodes,list_nodes_pid})
                end
            else
                # Yes Nearest longest+1 prefix match found
                # Send it to the given node with the incremented hop count
                #IO.inspect "Casting"
                GenServer.cast(elem(nearest_neighbour,0),{:route,key,elem(nearest_neighbour,1),b,hops+1,killed_nodes,alive_nodes,list_nodes_pid})
                #IO.puts "Send"

            end
           
        end

        #Combine the leafset small and big with sorting ended
        {:noreply,state}

    end

    # routing for No nearest longest+1 prefix match found
    def no_nearest_longestplus1_prefix_node(combineSet,d,a,l) do
        #IO.puts "#{inspect self()} #{inspect length(combineSet)} #{inspect d} #{inspect a} #{inspect l}"
        value=no_nearest_longestplus1_loop(combineSet,d,a,l,0,length(combineSet))
        value
    end 

    def no_nearest_longestplus1_loop(combineSet,d,a,l,start_value,length) do
        #IO.puts "#{inspect self()} #{inspect length(combineSet)} #{inspect d} #{inspect a} #{inspect l}"
        value = {-1,-1,-1}

        if(start_value<length) do
            shl=longest_prefix_matched(elem(Enum.at(combineSet,start_value),1),d,0,0)
            #IO.puts "#{shl} is shl_new"
           

            {t_changed,_}=Float.parse(elem(Enum.at(combineSet,start_value),1))
            {d_changed,_}=Float.parse(d)
            {a_changed,_}=Float.parse(a)

            if( shl>=l and 
                :erlang.abs(t_changed-d_changed)>:erlang.abs(a_changed-d_changed) and 
                start_value<length) do
                    #IO.inspect "I am here"
                    value=Enum.at(combineSet,start_value)
                   # IO.puts "Longest+1"
            else if(start_value<length) do
               #IO.puts "#{inspect self()} #{inspect length(combineSet)} #{inspect d} #{inspect a} #{inspect l}  #{inspect start_value} in less"
               value=no_nearest_longestplus1_loop(combineSet,d,a,l,start_value+1,length)   
            else  
            
                 end
            end

        end

        value
    end

    #Get the routing table with no null values
    def get_routing_table_row(routing_table,number_rows,number_columns,routing_table_list,row_index,column_index) do
        if(row_index<number_rows) do
            routing_table1=get_routing_table_column(routing_table,number_rows,number_columns,routing_table_list,row_index,column_index)
            routing_table_list=routing_table_list++routing_table1
            routing_table2=get_routing_table_row(routing_table,number_rows,number_columns,routing_table_list,row_index+1,column_index)
            routing_table_list=routing_table_list++routing_table2
        end

        #IO.inspect routing_table_list
        routing_table_list

    end


    def get_routing_table_column(routing_table,number_rows,number_columns,routing_table_list,row_index,column_index) do
         old_routing_table_list=routing_table_list
         if(column_index<number_columns) do
              if(elem(routing_table[row_index][column_index],2)!=-1) do
                 old_routing_table_list=old_routing_table_list++[routing_table[row_index][column_index]]
                 routing_table_list=old_routing_table_list
                 routing_table_list=get_routing_table_column(routing_table,number_rows,number_columns,routing_table_list,row_index,column_index+1)
              end
        end
        routing_table_list
    end

    #Get the count of the longest prefix count match
    def longest_prefix_matched(key,hash,start_value,longest_prefix_count) do
        
        {hash,_}=Float.parse(hash)
        hash=hash|>trunc
        hash=to_string(hash)
        #IO.puts "#{key} and #{hash}"
        if(String.at(key,start_value) == String.at(hash,start_value)) do
         longest_prefix_count=longest_prefix_matched(key,hash,start_value+1,longest_prefix_count+1)
        end
        longest_prefix_count
    end
    
    #Get the nearest neigbour for the given longest prefix count match
    #nearest_neighbour=nearest_neighbour(key,state[:routing_table][row],0,row,state[:number_columns])

    def nearest_neighbour(key,row,columnIndex,longest_prefix_count,num_columns) do
        nearest_neighbour_value={-1,-1,-1}
        #IO.puts "#{inspect self()} #{inspect row[columnIndex]} neareset  index #{columnIndex} num_columns #{num_columns}"
       if(columnIndex < num_columns) do
            if(elem(row[columnIndex],2)==-1) do
                 nearest_neighbour_value=nearest_neighbour(key,row,columnIndex+1,longest_prefix_count,num_columns)
            else
                 if(String.at(key,longest_prefix_count+1) != String.at(to_string(elem(row[columnIndex],1)),longest_prefix_count+1)) do
                         nearest_neighbour_value=nearest_neighbour(key,row,columnIndex+1,longest_prefix_count,num_columns)
                 else
                         nearest_neighbour_value=row[columnIndex]
                 end
            end
        end
        nearest_neighbour_value
       
    end

    def neighbor_set(node_list, index, start_value, neighbor_list) do
        if(start_value < 9 and length(node_list)!=0) do
            node_random = Enum.random(node_list)
            node_list = node_list -- [node_random]
            if ( :erlang.abs(elem(node_random,2)-index)> 2 or :erlang.abs(elem(node_random,2)-index) < 2) do
                neighbor_list = neighbor_list ++ [node_random]
            else
                # Do nothing
            end
            start_value=start_value+1
            neighbor_list=neighbor_set(node_list, index, start_value, neighbor_list)
        end
        neighbor_list
    end


    # Compute the larger Leaf Set for given node
    def larger_leaf_set(node_list,index,b,larger_leaf_set_list) do
        #IO.puts "#{inspect b} #{inspect index} #{inspect larger_leaf_set_list}"
        if((index==length(node_list) or index+1>length(node_list) or index+1==length(node_list)) and b>0)  do
                if(index+1==length(node_list) and b>0) do
                      larger_leaf_set_list=larger_leaf_set(node_list,-1,b,larger_leaf_set_list)
                else if(index+1>length(node_list) and b>0) do
                        larger_leaf_set_list=larger_leaf_set_list++[Enum.at(node_list,index)]
                        larger_leaf_set_list=larger_leaf_set(node_list,-1,b-1,larger_leaf_set_list)
                else if(index==length(node_list) and b>0) do
                        larger_leaf_set_list=larger_leaf_set_list++[Enum.at(node_list,index)]
                        larger_leaf_set_list=larger_leaf_set(node_list,-1,b-1,larger_leaf_set_list)
                     end
                  end
                end
        else if(b>0) do
                larger_leaf_set_list=larger_leaf_set_list++[Enum.at(node_list,index+1)]
                larger_leaf_set_list=larger_leaf_set(node_list,index+1,b-1,larger_leaf_set_list)
             end
        end
        larger_leaf_set_list
    end

    # Computer the small Leaf Set of given node
    def smaller_leaf_set(node_list,index,b,smaller_leaf_set_list) do
      if((index==1 or index-1<0 or index-1==0) and b>0)  do
                if(index-1==0 and b>0) do
                      smaller_leaf_set=smaller_leaf_set(node_list,length(node_list),b,smaller_leaf_set_list)
                else if(index-1<0 and b>0) do
                   smaller_leaf_set_list=smaller_leaf_set_list++[Enum.at(node_list,length(node_list)-1)]
                   smaller_leaf_set_list=smaller_leaf_set(node_list,length(node_list)-1,b-1,smaller_leaf_set_list)
                else if(index==1 and b>0) do
                        smaller_leaf_set_list=smaller_leaf_set_list++[Enum.at(node_list,length(node_list)-1)]
                        smaller_leaf_set_list=smaller_leaf_set(node_list,length(node_list)-1,b-1,smaller_leaf_set_list)
                     end
                  end
                end
        else if(b>0) do
                smaller_leaf_set_list=smaller_leaf_set_list++[Enum.at(node_list,index-1)]
                smaller_leaf_set_list=smaller_leaf_set(node_list,index-1,b-1,smaller_leaf_set_list)
             end
        end
        smaller_leaf_set_list
    end

    #Routing Table creation for a given node
    def create_routing_table_for_a_node(b,hashOfNode,nodelist) do
        numberOfColumns=trunc(:math.pow(2,b)-1) # 2^b-1 number of columns
        numberOfRows=round(:math.log(length(nodelist))/:math.log(:math.pow(2,b))) # log(N)/log(2^b)
        # Create a Map for the two dimensional array in elixir link(http://blog.danielberkompas.com/2016/04/23/multidimensional-arrays-in-elixir.html)
        routing_table=%{}
        # Routing table initialised
        #IO.puts "numberOfColumns = #{inspect numberOfColumns}" 
        #IO.puts "numberOfRows = #{inspect numberOfRows}" 

        routing_table=route_rows(nodelist,numberOfColumns,numberOfRows,0,hashOfNode,routing_table)
        #IO.puts "hashNode = #{inspect hashOfNode}" 
        #IO.puts "routing_table=#{inspect routing_table}"
        routing_table
    end


    def route_rows(node_list,numberOfColumns,numberOfRows,row_index,hashOfNode,routing_table) do
        if(row_index<numberOfRows) do
            if(row_index==0) do
                # IO.puts "#{row_index}"
                substring="";
                routing_table1=route_columns(node_list,numberOfColumns,numberOfRows,row_index,0,hashOfNode,substring,routing_table)
                routing_table=Map.merge(routing_table,routing_table1)
                routing_table2=route_rows(node_list,numberOfColumns,numberOfRows,row_index+1,hashOfNode,routing_table)
                routing_table=Map.merge(routing_table,routing_table2)

            else
                # IO.puts "#{row_index}"
                substring=String.slice(hashOfNode,0..row_index-1)
                routing_table1=route_columns(node_list,numberOfColumns,numberOfRows,row_index,0,hashOfNode,substring,routing_table)
                routing_table=Map.merge(routing_table,routing_table1)
                routing_table2=route_rows(node_list,numberOfColumns,numberOfRows,row_index+1,hashOfNode,routing_table)
                routing_table=Map.merge(routing_table,routing_table2)

            end          
        end 
        routing_table

    end

    def route_columns(node_list,numberOfColumns,numberOfRows,row_index,column_index,hashOfNode,substring,routing_table) do
        old_substring=substring
        if(column_index<numberOfColumns) do
            substring=substring<>to_string(column_index)
            value=find_element_in_list_match_substring(node_list,substring,hashOfNode)
               if(routing_table[row_index]!=nil) do
                    {_,updated_routing_table}=Map.get_and_update(routing_table,row_index,fn current_value -> {current_value,Map.merge(current_value,%{column_index => value})} end)
                    routing_table=Map.merge(routing_table,updated_routing_table)             
               else
                   {_,updated_routing_table}=Map.get_and_update(routing_table,row_index,fn current_value -> {current_value, %{column_index => value}} end)
                   routing_table=Map.merge(routing_table,updated_routing_table)
               end
            # end for updating the routing table
            routing_table=route_columns(node_list,numberOfColumns,numberOfRows,row_index,column_index+1,hashOfNode,old_substring,routing_table)
        end
        routing_table
    end

    def find_element_in_list_match_substring(node_list,substring,hashOfNode) do
        value={}
        value=find_element_loop(node_list,substring,0,value,hashOfNode)
        if tuple_size(value) <=0 do
            value={-1,-1,-1}
        end
        value
    end

    def find_element_loop(node_list,substring,index,value,hashOfNode) do
        if(index<length(node_list)) do
             if(String.starts_with?(elem(Enum.at(node_list,index),1),substring) and 
                elem(Enum.at(node_list,index),1)!=hashOfNode) do
                value=Enum.at(node_list,index)
             else
                value=find_element_loop(node_list,substring,index+1,value,hashOfNode)
             end
        end
        value
    end

    def get_new_Leafs(leafsets,killed_nodes,alive_nodes,list_nodes_pid) do
            newLeafsets=leafsets--killed_nodes
            #IO.puts "#{inspect self} #{inspect length(newLeafsets)} #{inspect length(leafsets)}" 
            if(length(newLeafsets)==length(leafsets)) do
            #No change in the leafset
            else
                deadLeafSetNodes=leafsets--alive_nodes
                # IO.puts "#{inspect self} #{inspect deadLeafSetNodes} dead" 
               newLeafsets=get_new_Leafs_due_to_dead(newLeafsets,length(deadLeafSetNodes),alive_nodes)
             end

            #O.puts "#{inspect self} #{inspect length(newLeafsets)} #{inspect length(leafsets)} after" 
            newLeafsets 
    end 

    def get_new_Leafs_due_to_dead(newLeafsets,index,alive_nodes) do

        if(index>0 and length(alive_nodes)>1) do
             newLeafsets=newLeafsets++[get_random_node(alive_nodes,newLeafsets,{})]
             newLeafsets=get_new_Leafs_due_to_dead(newLeafsets,index-1,alive_nodes)
        else    
            newLeafsets=newLeafsets++[get_random_node(alive_nodes,newLeafsets,{})]
        end
        newLeafsets
    end

    def get_random_node(alive_nodes,newLeafsets,value)do
        value={-1,-1,-1}
        random_node=Enum.random(alive_nodes)
        #IO.puts "#{inspect self} #{inspect random_node}"
        if(length(alive_nodes)==1) do
            value=random_node
        else if(Enum.member?(newLeafsets,random_node)) do
            value=get_random_node(alive_nodes,newLeafsets,value)
        else    
            value=random_node
            end
        end
        value
    end


     def get_new_neighbourhoodSet(neighbourset,killed_nodes,alive_nodes,list_nodes_pid) do
            newneighbourset=neighbourset--killed_nodes
            if(length(newneighbourset)==length(neighbourset)) do
            #No change in the leafset
            else
                deadneighbourhoodset=neighbourset--alive_nodes
                Enum.each(deadneighbourhoodset,fn(x)-> 
                     newneighbourset=newneighbourset++[get_random_node(alive_nodes,newneighbourset,{})]
                 end)
             end
            newneighbourset 
    end 

    def update_routing_table(routing_table,row_index,column_index,
                             numberRows,numberColumns,killed_nodes,alive_nodes,list_nodes_pid,
                             newrouting_table) do
            if(row_index<numberRows) do
                  #IO.puts "#{inspect routing_table} #{inspect routing_table[row_index]} is here"
                newrouting_table1=update_routing_table_column(routing_table,row_index,column_index,
                             numberRows,numberColumns,killed_nodes,alive_nodes,list_nodes_pid,
                             newrouting_table)

                newrouting_table= Map.merge(newrouting_table1,routing_table)
                routing_table=newrouting_table

                newrouting_table2=update_routing_table(routing_table,row_index+1,column_index,
                             numberRows,numberColumns,killed_nodes,alive_nodes,list_nodes_pid,
                             newrouting_table)

                newrouting_table= Map.merge(newrouting_table2,routing_table) 
                routing_table=newrouting_table     
            end

            newrouting_table
    end

    def update_routing_table_column(routing_table,row_index,column_index,
                             numberRows,numberColumns,killed_nodes,alive_nodes,list_nodes_pid,
                             newrouting_table) do

            if(column_index<numberColumns) do
              
                tuple=routing_table[row_index][column_index]
               
                if(elem(tuple,2)!=-1 and !Process.alive?(elem(tuple,0))) do
                    newtuplevalue=get_alive_nodes_for_routing_table(alive_nodes,String.slice(elem(tuple,1),row_index+1),killed_nodes,0)
                    {_,updated_routing_table}=Map.get_and_update(routing_table,row_index,fn current_value -> {current_value,%{column_index => newtuplevalue}} end)
                    routing_table=Map.merge(routing_table,updated_routing_table)   
                    newrouting_table=routing_table
                    routing_table=update_routing_table_column(routing_table,row_index,column_index+1,
                                                              numberRows,numberColumns,killed_nodes,alive_nodes,list_nodes_pid,
                                                              newrouting_table)
                end
            end

            newrouting_table

    end

    def get_alive_nodes_for_routing_table(alive_nodes,start_match,dead_nodes,index) do
        value={-1,-1,-1}
        if(String.starts_with?(elem(Enum.at(alive_nodes,index),1),start_match) or length(alive_nodes)==1) do
            value=Enum.at(alive_nodes,index)
        else
            value=get_alive_nodes_for_routing_table(alive_nodes,start_match,dead_nodes,index)
        end
        value
    end



end
