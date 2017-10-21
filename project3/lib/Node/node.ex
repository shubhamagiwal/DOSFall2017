defmodule Project3.Node do
use GenServer
    
    #Generate Node process
    def start(random_node_id) do
        hash=:crypto.hash(:md5, to_string(random_node_id)) |> Base.encode16 |> Convertat.from_base(16) |> Convertat.to_base(4)
        #IO.puts "#{inspect random_node_id} - #{inspect hash}"
        {:ok,pid} = GenServer.start_link(__MODULE__,hash)
        {pid,hash,random_node_id}
    end

    #Server Side Implementation
    def init(args) do  
        {:ok,%{:node_id => args}}
    end

    #update the larger leaf set , smaller leaf set

    def handle_cast({:updateLeafSet,larger_leaf_set,smaller_leaf_set,neighbor_set,routing_table,num_request},state) do
        {_,state_larger_leaf_set}=Map.get_and_update(state,:larger_leaf_set, fn current_value -> {current_value,larger_leaf_set} end)
        {_,state_smaller_leaf_set}=Map.get_and_update(state,:smaller_leaf_set, fn current_value -> {current_value,smaller_leaf_set} end)
        {_,state_neighbor_set}=Map.get_and_update(state,:neighbor_set, fn current_value -> {current_value,neighbor_set} end)
        {_,state_routing_table}=Map.get_and_update(state,:routing_table, fn current_value -> {current_value,routing_table} end)
        {_,state_num_request}=Map.get_and_update(state,:num_request, fn current_value -> {current_value,num_request} end)

        state=Map.merge(state,state_larger_leaf_set)
        state=Map.merge(state,state_smaller_leaf_set)
        state=Map.merge(state, state_neighbor_set)
        state=Map.merge(state, state_routing_table)
        state=Map.merge(state, state_num_request)

        #IO.puts "#{inspect state}"

        {:noreply,state}
    end

    def neighbor_set(node_list, index, start_value, neighbor_list) do
        if(start_value < 9) do
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

end
