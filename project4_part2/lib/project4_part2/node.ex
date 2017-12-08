defmodule Project4Part2.Node do
use GenServer
use Project4Part2Web, :channel


@numTweets 1
@numHashTags 1
@numberOfSubscriptions 1
@numTweetsFactor 1
@numClients 100
#Server Side Implementation
    def init(args) do 
        schedule_periodic_login_and_logout()
        {:ok,%{:is_logged_in=>true,:is_fresh_user=>true,:socket=> nil, :name_of_node => nil}}
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

    def handle_cast({:got_a_tweet,random_tweet,random_hashtag,original_tweeter,_,client_name_x,_},state) do

        if(state[:is_logged_in]==true) do
            push state[:socket],"got_tweet",%{ original_tweeter: original_tweeter, tweet: random_tweet, hashTag: random_hashtag, receiver: client_name_x }


            retweet_status=check_for_probability_for_retweet()

            if(retweet_status)do
                GenServer.cast(Boss_Server,{:got_retweet,client_name_x,random_tweet,random_hashtag,nil,original_tweeter,state[:socket]})
            end

        end
        {:noreply,state}
    end

    def handle_cast({:got_a_tweet_with_mention,reference,_,name_of_user,_,tweet,random_hashtag},state) do
        
        if(state[:is_logged_in]==true) do
           push state[:socket],"got_mention_tweet",%{reference: reference, name_of_user: name_of_user, tweet: tweet, random_hashtag: random_hashtag}

           retweet_status=check_for_probability_for_retweet()
            
           if(retweet_status)do
                #:got_retweet,client_name,random_tweet,random_hashtag,reference,original_tweeter,socket}
                GenServer.cast(Boss_Server,{:got_retweet,name_of_user,tweet,random_hashtag,reference,name_of_user,state[:socket]})
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
    
    def login(state)do
        #IO.inspect " I am login"
        GenServer.cast(Boss_Server,{:query,state[:name_of_node],state[:socket]})
        #push state[:socket], "login", %{client_name: state[:name_of_node]}
    end

    def start_client(id_tweeter,socket) do
        name_of_node=String.to_atom("tweeter@user"<>to_string(id_tweeter))
        #IO.inspect name_of_node
        #IO.inspect socket
        GenServer.start_link(__MODULE__,id_tweeter,name: name_of_node)
        GenServer.cast(name_of_node, {:update_socket_detail,socket,name_of_node})
        {name_of_node}
    end

end
