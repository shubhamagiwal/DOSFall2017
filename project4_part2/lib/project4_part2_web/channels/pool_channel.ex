defmodule Project4Part2Web.PoolChannel do
  use Project4Part2Web, :channel
  use GenServer
  

  def join("pool:client", _auth_message, socket)  do
      {:ok,socket}
  end

  def handle_in("create_user",%{"id"=> id},socket)do
      password=Project4Part2.LibFunctions.randomizer(8,true)        
      {clientName,pid}=start_client(id,socket)
      GenServer.cast(Boss_Server,{:created_user,clientName,password,id,socket,pid})
      IO.puts "{\"topic\":\"pool:client\",\"ref\":\"1\",\"payload\":{\"clientName\":\"#{clientName}\"},\"join_ref\":\"null\",\"event\":\"create_user\"}"  
      payload=%{"clientName" => clientName}    
      {:reply, {:ok,payload}, socket}
  end

  def handle_in("subscribe",%{"node" => node , "random_node_choose" => random_node_choose},socket)do
    #IO.inspect node
    GenServer.cast(Boss_Server,{:add_subscription_for_given_client_user,random_node_choose,node})
    GenServer.cast(Boss_Server,{:add_is_subscribed_for_given_client,random_node_choose,node})
    #Successful subscription Response is send to the Socket
    IO.puts "{\"topic\":\"pool:client\",\"ref\":\"1\",\"payload\":{\"response\":\"#{elem(node,0)} has subscribed to #{elem(random_node_choose,0)}\"},\"join_ref\":\"null\",\"event\":\"completed_subscription\"}"
    IO.puts "{\"topic\":\"pool:client\",\"ref\":\"1\",\"payload\":{\"response\":\"#{elem(random_node_choose,0)} is subscribed by #{elem(node,0)}\"},\"join_ref\":\"null\",\"event\":\"completed_subscription\"}"
    
    {:reply, :ok, socket}
  end

  def handle_in("tweet",  %{
      "name_of_user" => client_name,
      "hashTag" => hashTag,
      "tweet" => tweet,
      "reference" => reference,
      "isFreshUser" => isFreshUser,
      "pid" => pid
  }, socket) do
      GenServer.cast(Boss_Server,{:got_tweet,tweet,hashTag,client_name,reference,isFreshUser,socket,pid})
      IO.puts "{\"topic\":\"pool:client\",\"ref\":\"1\",\"payload\":{\"response\":\"#{client_name} has tweeted the given tweet \"#{tweet}\" with the given hashtag \"#{hashTag}\"\"},\"join_ref\":\"null\",\"event\":\"tweet\"}"      
      {:reply,:ok,socket}
     end

  def handle_in("mention_tweet",  %{
      "name_of_user" => client_name,
      "hashTag" => hashTag,
      "tweet" => tweet,
      "reference" => reference,
      "isFreshUser" => isFreshUser,
      "pid" => pid,
      "reference_pid" => reference_pid
  }, socket) do
      GenServer.cast(Boss_Server,{:got_mention_tweet,tweet,hashTag,client_name,reference,reference_pid,isFreshUser,socket,pid})
      IO.puts "{\"topic\":\"pool:client\",\"ref\":\"1\",\"payload\":{\"response\":\"#{client_name} has tweeted the given tweet \"#{tweet}\" with the given hashtag \"#{hashTag}\"\"},\"join_ref\":\"null\",\"event\":\"tweet\"}"      
      {:reply,:ok,socket}
     end

     def handle_in("retweet",  %{
      "name_of_user" => client_name,
      "hashTag" => hashTag,
      "tweet" => tweet,
      "isFreshUser" => isFreshUser,
      "pid" => pid
   }, socket) do
      #GenServer.cast(Boss_Server,{:got_mention_tweet,tweet,hashTag,client_name,reference,reference_pid,isFreshUser,socket,pid})
      #IO.puts "{\"topic\":\"pool:client\",\"ref\":\"1\",\"payload\":{\"response\":\"#{client_name} has tweeted the given tweet \"#{tweet}\" with the given hashtag \"#{hashTag}\"\"},\"join_ref\":\"null\",\"event\":\"tweet\"}" 
      IO.puts "Retweeting"     
      {:reply,:ok,socket}
     end

  def handle_in("hashTag_Subscription",%{
    "node" => node ,
    "hashTag" => list_of_preferred_hashtags_for_user
  },socket)do
    #IO.inspect node
    GenServer.cast(Boss_Server,{:assign_hashTags_to_user,node,list_of_preferred_hashtags_for_user,elem(node,3)})
    response=to_string(elem(node,0))<>" has subscribed to the list of hashtags as follows "<> to_string(Enum.join(list_of_preferred_hashtags_for_user, ","))    
    IO.puts "{\"topic\":\"pool:client\",\"ref\":\"1\",\"payload\":{\"response\":\"#{response}\"},\"join_ref\":\"null\",\"event\":\"subscribe_hashTag\"}"      

    {:reply,:ok,socket}
  end

    def handle_in("login",%{"client_name" => client_name},socket)do
      GenServer.cast(Boss_Server,{:query,client_name})
      {:reply,:ok,socket}
    end

    # def handle_in("got_tweet",  %{"original_tweeter" => original_tweeter, "tweet" => tweet, "hashTag" => hashTag, "receiver" => receiver}, socket) do
    #   IO.puts " I am here "
    #   IO.puts "#{inspect receiver} :Got a tweet #{inspect tweet} from  #{inspect original_tweeter} using socket #{inspect socket}"
    #   {:noreply,socket}
    # end

    # def handle_in("got_mention_tweet",  
    # %{"reference"=> reference, "name_of_user"=> name_of_user, "tweet"=>tweet, "random_hashtag"=> random_hashtag}, socket) do
    #   IO.puts "#{inspect reference} :Got a tweet #{inspect tweet} from  #{inspect name_of_user} using socket #{inspect socket}" 
    #   {:reply,:ok,socket}
    # end

    # def handle_in("got_retweet",  
    # %{ "tweet" => tweet, "hashTag" => hashtag, "receiver"=> receiver,"client_name_retweeting" => client_name_retweeting  }, socket) do
    #   IO.puts "#{inspect receiver} :Got a retweet #{inspect tweet} from  #{inspect client_name_retweeting} using socket #{inspect socket}" 
    #   {:reply,:ok,socket}
    # end

    # def handle_in("print",payload,socket)do
    #   IO.puts "I am here"

    #   {:noreply,socket}

    # end



    #Client Process Communication

    #Server Side Implementation
    def init(args) do 
      #schedule_periodic_login_and_logout()
      {:ok,%{:is_logged_in=>true,:is_fresh_user=>true,:socket=> nil, :name_of_node => nil}}
  end

  def handle_cast({:print},state)do
      IO.inspect "I mage"
      {:noreply,state}
  end

  def handle_cast({:update_socket_detail,socket,name_of_node},state)do
          #IO.inspect state
          {_,state_socket_detail}=Map.get_and_update(state,:socket, fn current_value -> {current_value,socket} end)
          state=Map.merge(state,state_socket_detail) 
          
          {_,state_name_node}=Map.get_and_update(state,:name_of_node, fn current_value -> {current_value,name_of_node} end)
          state=Map.merge(state,state_name_node)  

          {:noreply,state}
  end   

  def schedule_periodic_login_and_logout()do
      Process.send_after(self(), :periodic_login_and_logout, 2*1000) 
  end

  def handle_info(:periodic_login_and_logout, state) do
      if(state[:is_logged_in]==true)do
          #Do Logout
          {_,state_random_is_fresh_user}=Map.get_and_update(state,:is_logged_in, fn current_value -> {current_value,false} end)
          state=Map.merge(state,state_random_is_fresh_user)
      else
          #Do Login
          {_,state_random_is_fresh_user}=Map.get_and_update(state,:is_logged_in, fn current_value -> {current_value,true} end)
          state=Map.merge(state,state_random_is_fresh_user)    
          #IO.inspect state[:clientName]
          login(state)

      end
      schedule_periodic_login_and_logout() 
      {:noreply, state}
  end

  def handle_cast({:retweet,random_tweet,random_hashtag,name_of_user,client_node_name,reference,reference_node,original_tweet_node,original_tweet_user,socket,client_name_retweeting},state)do
        
        if(state[:is_logged_in]==true) do
              push state[:socket],"got_retweet",%{ tweet: random_tweet, hashTag: random_hashtag, receiver: name_of_user,client_name_retweeting: client_name_retweeting}
        end

      {:noreply,state}
  end

  def handle_cast({:got_a_tweet,random_tweet,random_hashtag,original_tweeter,reference,client_name_x,socket,pid},state) do
      
      #IO.inspect state[:is_logged_in]
     # IO.inspect state[:socket]

      if(state[:is_logged_in]==true) do
          #IO.inspect "Pushing Data"

          payload=to_string(client_name_x)<>" has got a tweet \""<> random_tweet <>"\" with given hashtag \""<>random_hashtag<>"\""<>" from user \""<>to_string(original_tweeter)<>"\""
          IO.puts "{\"topic\":\"pool:client\",\"ref\":\"1\",\"payload\":{\"response\":\"#{payload}\"},\"join_ref\":\"null\",\"event\":\"got_tweet\"}"  
          
          retweet_status=check_for_probability_for_retweet()

          if(retweet_status)do
              # GenServer.cast(Boss_Server,{:got_retweet,client_name_x,random_tweet,random_hashtag,nil,original_tweeter,state[:socket]})
              # "name_of_user" => client_name,
              # "hashTag" => hashTag,
              # "tweet" => tweet,
              # "isFreshUser" => isFreshUser,
              # "pid" => pid,
              Project4Part2Web.PoolChannelTest.retweet(client_name_x,random_hashtag,random_tweet,false,pid,socket)
          end

      end
      {:noreply,state}
  end

  def handle_cast({:got_a_tweet_with_mention,reference,reference_pid,name_of_user,name_of_user_pid,tweet,random_hashtag},state) do
      
      if(state[:is_logged_in]==true) do
           payload=to_string(reference)<>" has got a tweet \""<> tweet <>"\" with given hashtag \""<>random_hashtag<>"\""<>" from user \""<>to_string(name_of_user)<>"\""
           IO.puts "{\"topic\":\"pool:client\",\"ref\":\"1\",\"payload\":{\"response\":\"#{payload}\"},\"join_ref\":\"null\",\"event\":\"got_mention_tweet\"}"  
        
        #  if(retweet_status)do
        #       #:got_retweet,client_name,random_tweet,random_hashtag,reference,original_tweeter,socket}
        #       GenServer.cast(Boss_Server,{:got_retweet,name_of_user,tweet,random_hashtag,reference,name_of_user,state[:socket]})
        #  end

           
      
      end

       {:noreply,state}
  end

  def check_for_probability_for_retweet() do
      list=Enum.to_list(1..4)
      value=false
      if(Enum.random(list)==4) do
          value=true
      end
      value
  end
  
  def login(state)do
      #IO.inspect " I am login"
      GenServer.cast(Boss_Server,{:query,state[:name_of_node],state[:socket]})
      #push state[:socket], "login", %{client_name: state[:name_of_node]}
  end

  def start_client(id_tweeter,socket) do
      name_of_node=String.to_atom("tweeter:user"<>to_string(id_tweeter))
      #IO.inspect name_of_node
      #IO.inspect socket
      {:ok,pid}=GenServer.start_link(__MODULE__,id_tweeter,name: name_of_node)
      GenServer.cast(name_of_node, {:update_socket_detail,socket,name_of_node})
      {name_of_node,pid}
  end
  

end