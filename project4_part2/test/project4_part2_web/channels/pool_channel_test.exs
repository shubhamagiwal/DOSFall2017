defmodule Project4Part2Web.PoolChannelTest do
  use Project4Part2Web.ChannelCase, async: true
  use GenServer
  alias Project4Part2Web.PoolChannel

  @numNodes 10
  @numHashTags 1
  @random_number_subscriptions 1

  setup do

    list =Enum.to_list(1..@numNodes)
    
    socket_list=Enum.map(list, fn(x)-> 
      {:ok, _, socket} =
      socket("user_id"<>to_string(x), %{some: :assign})
      |> subscribe_and_join(PoolChannel, "pool:client")
      {socket,x}
    end)

    #Creating the users 
    Enum.map(socket_list,fn({socket_x,index})-> 
        push socket_x,"create_user",%{"id"=> index}
        Process.sleep(1_000) 
        {0,0}      
    end)

    list=GenServer.call(Boss_Server,{:get_list_users},:infinity)
    

    # Creating the initial tweets without any subscriptions
    Enum.each(list,fn({clientName,socket_x,_,pid})->
      
      tweet=Project4Part2.LibFunctions.randomizer(32,true)
      hashTag=Project4Part2.LibFunctions.randomizer(8,true)
      tweet=tweet<>" #"<>hashTag
      hashTag="#"<>hashTag

      push socket_x,"tweet",
      %{
      "name_of_user" => clientName,
      "hashTag" => hashTag,
      "tweet" => tweet,
      "reference" => nil,
      "isFreshUser" => false,
      "pid" => pid
      }

    end)

    #Get the hashTag List from the server after initial tweets are done
    hashTagList=GenServer.call(Boss_Server,{:get_hashTags},:infinity)
    

    #Random Subscriptions
    list=random_subscriptions(list,0)
    GenServer.cast(Boss_Server,{:update_list,list})
    
    #Subscribe to Number number of hashTags
    random_hashTags_for_a_given_user(hashTagList,list,0)


    # Tweet each user another set of tweets after all the initial setup
    Enum.each(list,fn({clientName,socket_x,_,pid}) -> 
      
      tweet=Project4Part2.LibFunctions.randomizer(32,true)
      hashTag=Project4Part2.LibFunctions.randomizer(8,true)
      tweet=tweet<>" #"<>hashTag
      hashTag="#"<>hashTag


      push socket_x,"tweet",%{
       "name_of_user" => clientName,
       "hashTag" => hashTag,
       "tweet" => tweet,
       "reference" => nil,
       "isFreshUser" => false,
       "pid" => pid
     }

    end)


    #Calculate Zipf Tweets 
    IO.puts "Started computing with the Zipf Tweets for the simulation"
    GenServer.cast(Boss_Server,{:calculate_zipf_tweets,list,length(list)})
    


    # Tweet each user @mention of tweets after all the initial setup
     Enum.each(list,fn({clientName,socket_x,value,pid}) -> 
      
      tweet=Project4Part2.LibFunctions.randomizer(32,true)
      hashTag=Project4Part2.LibFunctions.randomizer(8,true)
      new_list=list--[{clientName,socket_x,value,pid}]
      
      random_user=Enum.random(new_list)

      tweet=tweet<>" #"<>hashTag
      tweet= tweet<> " @"<>to_string(elem(random_user,0))
      hashTag="#"<>hashTag


      push socket_x,"mention_tweet",%{
        "name_of_user" => clientName,
        "hashTag" => hashTag,
        "tweet" => tweet,
        "reference" => elem(random_user,0),
        "isFreshUser" => false,
        "pid" => pid,
        "reference_pid" => elem(random_user,3)
     }

     Process.sleep(1_000)
     
  end)

  #Start the  login and logout functionality of the given user
  Enum.each(list,fn({clientName,socket_x,_,pid}) -> 

    push socket_x,"logout",%{
      "client_name" => clientName,
      "pid" => pid}
    
    Process.sleep(1_000)
    
    push socket_x,"login",%{
      "client_name" => clientName,
      "pid" => pid}
   
  end)

  # Start Zipf Distribution
  GenServer.cast(Boss_Server,{:zipf_distribution})



    {:ok, socket: list}
  end

  test "create_users", %{socket: socket_list} do
    Process.sleep(20_0000)
    assert 1=1
  end

  def random_subscriptions(list, start) do
    if(start<=length(list)) do
        #listLength=length(list)
        #numberList=1..listLength
        #random_number_subscriptions=Enum.random(numberList)-1
        random_number_subscriptions=@random_number_subscriptions
        element=Enum.at(list,start-1)
        newList=list--[element]
        generate_subscriptions(newList,1,random_number_subscriptions,element)
        
        tuple_1=Tuple.delete_at(element,2)
        element=Tuple.insert_at(tuple_1, 2,random_number_subscriptions)
        newList=List.delete_at(list,start-1)
        list=List.insert_at(newList, start-1,element )
        start=start+1
        list=random_subscriptions(list, start) 
    end
    list         
end

def generate_subscriptions(list,startValue,random_number_subscriptions,node)do
   if(startValue<=random_number_subscriptions) do
       random_node_choose=Enum.random(list);
       list=list--[random_node_choose]
       push elem(node,1),"subscribe",%{"node" => node , "random_node_choose" => random_node_choose}
       Process.sleep(1_000)       
       startValue=startValue+1;
       generate_subscriptions(list,startValue,random_number_subscriptions,node)
   end 
end


    # Random Subscriptions Utilities
def random_hashTags_for_a_given_user(hashTagList,list,start) do
      
      if(start<=length(list)) do
          element=Enum.at(list,start-1);
          list_of_preferred_hashtags_for_user=Enum.take_random(hashTagList,@numHashTags)
          push elem(element,1),"hashTag_Subscription",%{"node" => element , "hashTag" => list_of_preferred_hashtags_for_user}
          Process.sleep(1_000)                 
          start=start+1

          random_hashTags_for_a_given_user(hashTagList,list,start) 
      end
end

def retweet(client_name_x,random_hashtag,random_tweet,isFreshUser,pid,socket)do
    #Retweeting function
    push socket,"retweet",%{ "name_of_user" => client_name_x, "hashTag" => random_hashtag, "tweet" => random_tweet, "isFreshUser" => isFreshUser, "pid" => pid}
end

end
