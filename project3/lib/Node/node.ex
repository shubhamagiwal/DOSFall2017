defmodule Project3.Node do
use GenServer
    
    #Generate Node process
    def start(random_node_id) do
        # Here Node Space is 2^128-1
        #node_Id=Project3.LibFunctions.randomizer(37,:numeric);
        hash=:crypto.hash(:sha256, to_string(random_node_id)) |> Base.encode16
        IO.puts "#{inspect random_node_id} - #{inspect hash}"
        {:ok,pid} = GenServer.start_link(__MODULE__,hash)
        {pid,hash,random_node_id}
    end

    #Server Side Implementation
    def init(args) do  
        {:ok,%{:node_id => args}}
    end

    #update the larger leaf set and smaller leaf set

    def handle_cast({:updateLeafSet,larger_leaf_set,smaller_leaf_set},state) do
        {_,state_larger_leaf_set}=Map.get_and_update(state,:larger_leaf_set, fn current_value -> {current_value,larger_leaf_set} end)
        {_,state_smaller_leaf_set}=Map.get_and_update(state,:smaller_leaf_set, fn current_value -> {current_value,smaller_leaf_set} end)
       
        state=Map.merge(state,state_larger_leaf_set)
        state=Map.merge(state,state_smaller_leaf_set)

        IO.puts "#{inspect state}"

        {:noreply,state}
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

end
