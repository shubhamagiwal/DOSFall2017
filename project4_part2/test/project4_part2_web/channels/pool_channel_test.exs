defmodule Project4Part2Web.PoolChannelTest do
  use Project4Part2Web.ChannelCase, async: true
  use GenServer
  alias Project4Part2Web.PoolChannel
  require IEx

  @numNodes 10
  @numHashTags 1

  setup do

    list =Enum.to_list(1..@numNodes)
    
    socket_list=Enum.map(list, fn(x)-> 
      {:ok, _, socket} =
      socket("user_id"<>to_string(x), %{some: :assign})
      |> subscribe_and_join(PoolChannel, "pool:client"<>to_string(x))
      {socket,x}
    end)

    #IO.inspect socket_list

    #Creating the users 
    list=Enum.map(socket_list,fn({socket_x,index})-> 
      #push socket_x, "create_user", %{"id" => index}
      #user=String.to_atom("tweeter@user"<>to_string(index))
      
      #clientName=String.to_atom("tweeter@user"<>to_string(index))
      password=Project4Part2.LibFunctions.randomizer(8,true)        
      {clientName,pid}=Project4Part2.Node.start_client(index,socket_x)
      GenServer.cast(Boss_Server,{:created_user,clientName,password,index,socket})

      #tweet details
      random_tweet_text=Project4Part2.LibFunctions.randomizer(32,:downcase)
      random_hashTag="#"<>Project4Part2.LibFunctions.randomizer(8,true)      
      
      push socket_x,"tweet",%{
        "name_of_user" => clientName,
        "hashTag" => random_hashTag,
        "tweet" => random_tweet_text,
        "reference" => nil,
        "isFreshUser" => true
      }

      Process.sleep(1_000)      

      #GenServer.cast(clientName,{:print})

      {clientName,socket_x,0,pid}      
    end)

    
    

    #Random Subscriptions
    list=Project4Part2.LibFunctions.random_subscriptions(list, 0)

    #update the list with the random subscriptions
    GenServer.cast(Boss_Server,{:update_list,list})

    #Random HashTags for the user
    Project4Part2.LibFunctions.random_hashTags_for_a_given_user(@numHashTags,list,0)
   

    Enum.each(list,fn({clientName,socket_x,value,pid}) -> 
      #IO.inspect "i ma herer"
      push socket_x,"tweet",%{
       "name_of_user" => clientName,
       "hashTag" => "1sdsdsf#aess",
       "tweet" => "asdf",
       "reference" => nil,
       "isFreshUser" => false
     }

     Process.sleep(1_000)      
     
   end)


  
    
    {:ok, socket: list}
  end

  test "create_users", %{socket: socket_list} do
    #IO.inspect socket_list

    # Enum.each(socket_list,fn({clientName,socket_x,value})-> 
    #   IO.inspect clientName 
    #   IO.inspect Process.whereis(clientName)
    #   GenServer.cast(clientName,{:print}) end)

   
    assert 1=1
  end

  # test "shout broadcasts to pool:lobby", %{socket: socket} do
  #   push socket, "shout", %{"hello" => "all"}
  #   assert_broadcast "shout", %{"hello" => "all"}
  # end

  # test "broadcasts are pushed to the client", %{socket: socket} do
  #   broadcast_from! socket, "broadcast", %{"some" => "data"}
  #   assert_push "broadcast", %{"some" => "data"}
  # end
end
