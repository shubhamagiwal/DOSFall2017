defmodule Project4Part2.Node do
use GenServer

@numTweets 1
@numHashTags 1
@numberOfSubscriptions 1
@numTweetsFactor 1
@numClients 100
#Server Side Implementation
    def init(args) do  
        schedule_periodic_login_and_logout()
        {:ok,%{:is_logged_in=>true,:is_fresh_user=>true,:boss_node=>args, :clientName => nil, :clientNode => nil,:retweet_list_buffer => [], :tweet_list_buffer => [] , :mention_tweet_buffer => [] }}
    end

    def schedule_periodic_login_and_logout()do
        Process.send_after(self(), :periodic_login_and_logout, 20*1000) 
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
            GenServer.cast(state[:clientName],{:login})

        end

        schedule_periodic_login_and_logout() 
        {:noreply, state}
    end


    def handle_cast({:tweet,name_of_user,client_node_name,reference},state)do
        server_node_name=state[:boss_node]

        if(state[:is_logged_in]==true and state[:is_fresh_user]==true) do
            
            random_tweet_text=Project4Part1.LibFunctions.randomizer(32,:downcase)
            random_hashTag="#"<>Project4Part1.LibFunctions.randomizer(8,true)
            random_tweet=random_tweet_text<>random_hashTag

            #IO.inspect random_tweet

            GenServer.cast({Boss_Server,server_node_name},{:got_tweet,random_tweet,random_hashTag,name_of_user,client_node_name,reference,state[:is_fresh_user]})

            # Update the is_fresh_user status to false
            {_,state_random_is_fresh_user}=Map.get_and_update(state,:is_fresh_user, fn current_value -> {current_value,false} end)
            state=Map.merge(state,state_random_is_fresh_user)

        else if(state[:is_logged_in]==true and state[:is_fresh_user]==false) do
            
            random_tweet_text=Project4Part1.LibFunctions.randomizer(32,:downcase)
            random_hashTag="#"<>Project4Part1.LibFunctions.randomizer(8,true)
            random_tweet=random_tweet_text<>random_hashTag
             # IO.inspect random_tweet
            GenServer.cast({Boss_Server,server_node_name},{:got_tweet,random_tweet,random_hashTag,name_of_user,client_node_name,reference,state[:is_fresh_user]})

        else
            #Do Nothing
             end
        end

        {:noreply,state}
    end

    def handle_cast({:mention_tweet,client_node_name,name_of_user},state)do
        server_node_name=state[:boss_node]
        {_,hashTag,tweet,_,reference,reference_node}=GenServer.call({Boss_Server,server_node_name},{:get_random_tweet_for_mention,name_of_user,client_node_name},:infinity)
        tweet=tweet<>" @"<>to_string(reference)
        GenServer.cast({Boss_Server,server_node_name},{:got_mention_tweet,client_node_name,name_of_user,tweet,hashTag,reference,reference_node})
        #GenServer.cast({Boss_Server,server_node_name},{:get_random_tweet_for_mention,name_of_user,client_node_name})
        {:noreply,state}
     end

    def handle_cast({:retweet,random_tweet,random_hashtag,name_of_user,client_node_name,reference,reference_node,original_tweet_node,original_tweet_user},state)do
          if(state[:is_logged_in]==true) do
                IO.puts "#{inspect name_of_user} of #{inspect client_node_name}:Got a retweet #{inspect random_tweet} from  #{inspect original_tweet_user} of  #{inspect original_tweet_node} "
          end
        {:noreply,state}
    end

    def handle_cast({:got_a_tweet,random_tweet,random_hashtag,name_of_user,client_node_name,_,client_name_x,client_node_name_x},state) do
        server_node_name=state[:boss_node]

        #IO.inspect random_tweet
        #IO.inspect state[:is_logged_in]
        if(state[:is_logged_in]==true) do
            IO.puts "#{inspect client_name_x} of #{inspect client_node_name_x}:Got a tweet #{inspect random_tweet} from  #{inspect name_of_user} of  #{inspect client_node_name} "
            retweet_status=check_for_probability_for_retweet()

            if(retweet_status)do
                GenServer.cast({Boss_Server,server_node_name},{:got_retweet,client_node_name_x,client_name_x,random_tweet,random_hashtag,name_of_user,client_node_name})
            end

        end
        {:noreply,state}
    end

    def handle_cast({:got_a_tweet_with_mention,reference,reference_node,name_of_user,client_node_name,tweet,random_hashtag},state) do
        
        server_node_name=state[:boss_node]

        if(state[:is_logged_in]==true) do
           IO.puts "#{inspect reference} of #{inspect reference_node}:Got a tweet #{inspect tweet} from  #{inspect name_of_user} of  #{inspect client_node_name} " 

           retweet_status=check_for_probability_for_retweet()
            
           if(retweet_status)do
                GenServer.cast({Boss_Server,server_node_name},{:got_retweet,reference_node,reference,tweet,random_hashtag,name_of_user,client_node_name})
           end
        
        end

         {:noreply,state}
    end

    def check_for_probability_for_retweet() do
        list=Enum.to_list(1..1000)
        value=false
        if(Enum.random(list)==4) do
            value=true
        end
        value
    end
 
    def handle_cast({:login},state)do
          # {:ok,%{:is_logged_in=>true,:is_fresh_user=>true,:boss_node=>args, :clientName => nil, :clientNode => nil }}
          GenServer.cast({Boss_Server,state[:boss_node]},{:query,state[:clientNode],state[:clientName]})
          {:noreply,state}
     end

    def handle_cast({:update_client_state,clientName,clientNode},state)do

        {_,state_isLoggedIn}=Map.get_and_update(state,:clientName, fn current_value -> {current_value,clientName} end)
        state=Map.merge(state,state_isLoggedIn)

        {_,state_isLoggedIn}=Map.get_and_update(state,:clientNode, fn current_value -> {current_value,clientNode} end)
        state=Map.merge(state,state_isLoggedIn)

        {_,state_isLoggedIn}=Map.get_and_update(state,:is_fresh_user, fn current_value -> {current_value,false} end)
        state=Map.merge(state,state_isLoggedIn)
        
        {:noreply,state}
    end

    #Client Side Implementation

    #start process on the given node for a given client node

    def start_link()do
        
        
        #Start the Boss Server Process
        Project4Part2.Boss.start_link()

        #numClients For the given Server
        numOfClients= @numClients
        numList=Enum.to_list(1..numOfClients)
        IO.inspect numList

        l=Enum.each(numList, fn(x)-> start(x) end)
        IO.inspect l
       
        loop()
    end

    def loop() do
        loop()
    end

    def start(id_tweeter) do
        name_of_node=String.to_atom("tweeter@user"<>to_string(id_tweeter))
        password=Project4Part2.LibFunctions.randomizer(8,true)
        {:ok, pid} = PhoenixChannelClient.start_link()        
        {:ok, socket} = PhoenixChannelClient.connect(pid,host: "0.0.0.0", port: 4000,  path: "/socket/websocket")        
        channel = PhoenixChannelClient.channel(socket, "pool:client"<>to_string(id_tweeter), %{})
        
        case PhoenixChannelClient.join(channel) do
            {:ok, message} -> IO.inspect(message)
            {:error, %{"reason" => reason}} -> IO.puts(reason)
            :timeout -> IO.puts("timeout")
        end

        PhoenixChannelClient.push(channel, "new_msg", %{text: "Hello"})
        GenServer.cast(Boss_Server, {:print,"Awesome"})

        {name_of_node,socket,channel}
    end
    
end
