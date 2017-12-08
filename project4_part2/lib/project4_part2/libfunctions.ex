defmodule Project4Part2.LibFunctions do

#https://gist.github.com/ahmadshah/8d978bbc550128cca12dd917a09ddfb7
 def randomizer(length, type \\ :all) do
    alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    numbers = "0123456789"

    lists =
      cond do
        type == :alpha ->String.downcase(alphabets)
        type == :numeric -> numbers
        type == :upcase -> alphabets
        type == :downcase -> String.downcase(alphabets)
        true -> String.downcase(alphabets) <> numbers
      end
      |> String.split("", trim: true)

    do_randomizer(length, lists)
  end

  @doc false
  defp get_range(length) when length > 1, do: (1..length)
  defp get_range(length), do: [1]

  @doc false
  defp do_randomizer(length, lists) do
    get_range(length)
    |> Enum.reduce([], fn(_, acc) -> [Enum.random(lists) | acc] end)
    |> Enum.join("")
  end


    # Random Subscriptions Utilities
        def random_subscriptions(list, start) do
            if(start<=length(list)) do
                listLength=length(list)
                numberList=1..listLength
                random_number_subscriptions=Enum.random(numberList)-1
                #random_number_subscriptions=1
                element=Enum.at(list,start-1);
                newList=list--[element]
                #IO.inspect newList
                generate_subscriptions(newList,1,random_number_subscriptions,element)
                
                tuple_1=Tuple.delete_at(element,2)
                element=Tuple.insert_at(tuple_1, 2,random_number_subscriptions)
                 
                #IO.inspect element
                
                newList=List.delete_at(list,start-1)
                list=List.insert_at(newList, start-1,element )
                #elem(list,2)=random_number_subscriptions
                start=start+1
                list=random_subscriptions(list, start) 
            end
            list         
        end
    
        def generate_subscriptions(list,startValue,random_number_subscriptions,node)do
           if(startValue<=random_number_subscriptions) do
               random_node_choose=Enum.random(list);
               #IO.inspect random_node_choose
               list=list--[random_node_choose]
               #IO.puts "I am here"
               GenServer.cast(Boss_Server,{:add_subscription_for_given_client_user,random_node_choose,node})
               GenServer.cast(Boss_Server,{:add_is_subscribed_for_given_client,random_node_choose,node})
               startValue=startValue+1;
               generate_subscriptions(list,startValue,random_number_subscriptions,node)
           end 
        end

        def random_hashTags_for_a_given_user(numHashTags,list,start) do
          
          if(start<=length(list)) do
              element=Enum.at(list,start-1);
              GenServer.cast(Boss_Server,{:assign_hashTags_to_user,numHashTags,element})
              start=start+1
              random_hashTags_for_a_given_user(numHashTags,list,start) 
          end

      end



        
    

end
