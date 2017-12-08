defmodule Project4Part2.Boss do
use GenServer
use Project4Part2Web, :channel

@numTweetsForZipf 100
@s 1


def start_link()do
        GenServer.start_link(__MODULE__,:ok, name: Boss_Server)  
end


def init(:ok) do
        schedule_periodic_computation_for_tweets_and_retweets()
        #ETS start
        :ets.new(:users, [:bag, :protected, :named_table])
        :ets.new(:hashTags, [:bag, :protected, :named_table])
        :ets.new(:tweets, [:bag, :protected, :named_table])
        :ets.new(:user_mention_tweets, [:bag, :protected, :named_table])
        :ets.new(:retweets, [:bag, :protected, :named_table])
        :ets.new(:user_list, [:set, :protected, :named_table])
        :ets.new(:client_zipf_details_per_client_node,[:set, :protected, :named_table])
        #:ets.new(:user_list_with_subscription,[:set, :protected, :named_table])

        :ets.insert_new(:user_list,{"user_list",[]})
        #:ets.insert_new(:user_list_with_subscription,{:user_list_with_subscription,[]})
        #ETS End

        {:ok,%{:start_value=>1,:number_of_tweets_before=>0, :number_of_tweets_after=>0, :number_of_retweets_before=>0,:number_of_retweets_after=>0,:hashTag=>[],:count_numClients=>0,:numClients=>0}}
end

def schedule_periodic_computation_for_tweets_and_retweets() do
        Process.send_after(self(), :periodic_computation_for_tweets_and_retweets, 5*1000)
end

def handle_info(:periodic_computation_for_tweets_and_retweets, state) do
        number_of_tweets=state[:number_of_tweets_after] - state[:number_of_tweets_before]
        number_of_retweets=state[:number_of_retweets_after]-state[:number_of_retweets_before]
        
        number_of_tweets_after=state[:number_of_tweets_after]
        number_of_retweets_after=state[:number_of_retweets_after]

        {_,state_retweets}=Map.get_and_update(state,:number_of_retweets_before, fn current_value -> {current_value,number_of_retweets_after} end)
        state=Map.merge(state,state_retweets)

        {_,state_tweets}=Map.get_and_update(state,:number_of_tweets_before, fn current_value -> {current_value,number_of_tweets_after} end)
        state=Map.merge(state,state_tweets)

        IO.puts "Number of tweets per 5 second = #{inspect number_of_tweets}"
        IO.puts "Number of retweets per 5 second = #{inspect number_of_retweets}"

         schedule_periodic_computation_for_tweets_and_retweets()
        {:noreply, state}
end

def handle_call({:get_list_users},_from,state)do
        array_list=:ets.lookup(:user_list, "user_list")
        elem_tuple=Enum.at(array_list,0)
        list=elem(elem_tuple,1)
        {:reply,list,state} 
end

def handle_cast({:created_user,clientName,password,id,socket},state)do

      id=String.to_integer(id)

      process_map=%{:socket => nil, :hashTags => [], :password => nil, :has_subscribed_to => [], :is_subscribed_by => [],:name_node => nil, :id => nil, :no_of_zipf_tweets =>0, :probability_of_zipf_functions=>0, :number_of_subscribers=>0 }

      {_,state_name_node}=Map.get_and_update(process_map,:name_node, fn current_value -> {current_value,clientName} end)
      process_map=Map.merge(process_map,state_name_node)

      {_,state_password}=Map.get_and_update(process_map,:password, fn current_value -> {current_value,password} end)
      process_map=Map.merge(process_map,state_password)

      {_,state_id}=Map.get_and_update(process_map,:id, fn current_value -> {current_value,id} end)
      process_map=Map.merge(process_map,state_id)

      {_,state_socket}=Map.get_and_update(process_map,:socket, fn current_value -> {current_value,socket} end)
      process_map=Map.merge(process_map,state_socket)


      #Update the user_list with the client and node tuple
      #{name_of_node,client_node_name}
        array_list=:ets.lookup(:user_list, "user_list")
        elem_tuple=Enum.at(array_list,0)
        list=elem(elem_tuple,1)
        list=list++[{clientName,socket,0}]
        :ets.insert(:user_list,{"user_list",list})

        #Added it to the users table
        :ets.insert(:users,{clientName,process_map})
        IO.inspect process_map
        IO.inspect self()

      {:noreply,state}
end

def handle_cast({:got_tweet,random_tweet,random_hashTag,name_of_user,reference,isFreshUser,socket},state)do

        # :ets.new(:users, [:bag, :protected, :named_table])
        # :ets.new(:hashTags, [:bag, :protected, :named_table])
        # :ets.new(:tweets, [:bag, :protected, :named_table])
        # :ets.new(:user_mention_tweets, [:bag, :protected, :named_table])
        # :ets.new(:retweets, [:bag, :protected, :named_table])
        # :ets.new(:user_list, [:set, :protected, :named_table])

        #Change Tweets Table

        #IO.inspect random_tweet

        process_map_tweets_table=%{:tweet => nil, :hashTag => nil, :name_of_user => nil, :socket => nil, :reference => nil,:reference_node=>nil}

        {_,random_tweet_1}=Map.get_and_update(process_map_tweets_table,:tweet, fn current_value -> {current_value,random_tweet} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,random_tweet_1)

        {_,hashTag_1}=Map.get_and_update(process_map_tweets_table,:hashTag, fn current_value -> {current_value,random_hashTag} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,hashTag_1)

        {_,name_of_user_1}=Map.get_and_update(process_map_tweets_table,:name_of_user, fn current_value -> {current_value,name_of_user} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,name_of_user_1)

        {_,name_of_socket_1}=Map.get_and_update(process_map_tweets_table,:socket, fn current_value -> {current_value,socket} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,name_of_socket_1)

        {_,reference_1}=Map.get_and_update(process_map_tweets_table,:reference, fn current_value -> {current_value,reference} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,reference_1)
        
        :ets.insert(:tweets,{name_of_user,process_map_tweets_table})

        #################################################

        #Change only HashTags 

        process_map_hashTag_table=%{:tweet => nil, :hashTag => nil, :name_of_user => nil, :socket => nil, :reference => nil,:reference_node=>nil}

        {_,random_tweet_1}=Map.get_and_update(process_map_hashTag_table,:tweet, fn current_value -> {current_value,random_tweet} end)
        process_map_hashTag_table=Map.merge(process_map_hashTag_table,random_tweet_1)

        {_,hashTag_1}=Map.get_and_update(process_map_hashTag_table,:hashTag, fn current_value -> {current_value,random_hashTag} end)
        process_map_hashTag_table=Map.merge(process_map_hashTag_table,hashTag_1)

        {_,name_of_user_1}=Map.get_and_update(process_map_hashTag_table,:name_of_user, fn current_value -> {current_value,name_of_user} end)
        process_map_hashTag_table=Map.merge(process_map_hashTag_table,name_of_user_1)

        {_,client_socket}=Map.get_and_update(process_map_hashTag_table,:client_node_name, fn current_value -> {current_value,socket} end)
        process_map_hashTag_table=Map.merge(process_map_hashTag_table,client_socket)

        {_,reference_1}=Map.get_and_update(process_map_hashTag_table,:reference, fn current_value -> {current_value,reference} end)
        process_map_hashTag_table=Map.merge(process_map_hashTag_table,reference_1)
        
        :ets.insert(:hashTags,{random_hashTag,process_map_hashTag_table})

         {_,state_tweets}=Map.get_and_update(state,:number_of_tweets_after, fn current_value -> {current_value,current_value+1} end)
         state=Map.merge(state,state_tweets)
        
         # {:ok,%{:start_value=>1,:number_of_tweets_before=>0, :number_of_tweets_after=>0, :number_of_retweets_before=>0,:hashTag=>[]}}

        {_,state_hashTag}=Map.get_and_update(state,:hashTag, fn current_value -> {current_value,current_value++[random_hashTag]} end)
        state=Map.merge(state,state_hashTag)    
          
         
        #IO.inspect "#{inspect random_hashTag} #{inspect state[:hashTag]}"

        client_name=name_of_user
        
        if(isFreshUser!=true) do
           is_subscribed_by=get_a_list_of_is_subscribed_by_for_given_client(client_name,state)
           #{:got_a_tweet,random_tweet,random_hashtag,name_of_user,client_node_name,_,client_name_x,client_node_name_x}
           Enum.each(is_subscribed_by,fn({client_name_x,socket_x,0}) -> 
                
                #:got_tweet,random_tweet,random_hashTag,name_of_user,reference,isFreshUser,socket

                GenServer.cast({client_name_x},{:got_a_tweet,random_tweet,random_hashTag,name_of_user,reference,client_name_x,socket_x})  end)
        end 

        {:noreply,state}
end

def get_a_list_of_is_subscribed_by_for_given_client(client_name,state) do
        array_list=:ets.lookup(:users,client_name)
        elem_tuple=Enum.at(array_list,0)
        users_tuple=elem(elem_tuple,1)
        is_subscribed_by=users_tuple[:is_subscribed_by]
        is_subscribed_by
end

def handle_cast({:add_subscription_for_given_client_user,random_node_choose,node},state)do
         # process_map=%{:node_client => nil, :hashTags => [], :password => nil, :has_subscribed_to => [], :is_subscribed_by => [],:name_node => nil, :id => nil}
         client_name=elem(node,0)
         client_node=elem(node,1)

         array_list=:ets.lookup(:users, client_name)
         elem_tuple=Enum.at(array_list,0)
         users_tuple=elem(elem_tuple,1)

         users_tuple_has_subscribed_to=users_tuple[:has_subscribed_to]
         users_tuple_has_subscribed_to=users_tuple_has_subscribed_to++[random_node_choose]
         
         
        {_,state_random_has_subscribed_to}=Map.get_and_update(users_tuple,:has_subscribed_to, fn current_value -> {current_value,users_tuple_has_subscribed_to} end)
         users_tuple=Map.merge(users_tuple,state_random_has_subscribed_to)

         :ets.delete(:users,client_name)
         :ets.insert(:users, {client_name,users_tuple})

         {:noreply,state}
end

def handle_cast({:got_retweet,client_name,tweet,hashTag,reference,original_tweeter,socket},state) do

        # :ets.new(:users, [:bag, :protected, :named_table])
        # :ets.new(:hashTags, [:bag, :protected, :named_table])
        # :ets.new(:tweets, [:bag, :protected, :named_table])
        # :ets.new(:user_mention_tweets, [:bag, :protected, :named_table])
        # :ets.new(:retweets, [:bag, :protected, :named_table])
        # :ets.new(:user_list, [:set, :protected, :named_table])

       #Change Tweets Table

        process_map_tweets_table=%{:tweet => nil, :hashTag => nil, :name_of_user => nil, :socket => nil, :reference => nil,:reference_node=>nil,:original_tweeter=>nil}

        {_,random_tweet_1}=Map.get_and_update(process_map_tweets_table,:tweet, fn current_value -> {current_value,tweet} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,random_tweet_1)

        {_,hashTag_1}=Map.get_and_update(process_map_tweets_table,:hashTag, fn current_value -> {current_value,hashTag} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,hashTag_1)

        {_,name_of_user_1}=Map.get_and_update(process_map_tweets_table,:name_of_user, fn current_value -> {current_value,client_name} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,name_of_user_1)

        {_,client_socket_1}=Map.get_and_update(process_map_tweets_table,:socket, fn current_value -> {current_value,socket} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,client_socket_1)

        {_,reference_1}=Map.get_and_update(process_map_tweets_table,:reference, fn current_value -> {current_value,reference} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,reference_1)

        {_,original_tweeter_1}=Map.get_and_update(process_map_tweets_table,:original_tweeter, fn current_value -> {current_value,original_tweeter} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,original_tweeter_1)
        
        :ets.insert(:tweets,{client_name,process_map_tweets_table})

        ############################################################################

        #Change only Retweets Table 

        process_map_retweets_table=%{:tweet => nil, :hashTag => nil, :name_of_user => nil, :socket => nil, :reference => nil,:reference_node=>nil,:original_tweeter=>nil}

        {_,random_tweet_1}=Map.get_and_update(process_map_retweets_table,:tweet, fn current_value -> {current_value,tweet} end)
        process_map_retweets_table=Map.merge(process_map_retweets_table,random_tweet_1)

        {_,hashTag_1}=Map.get_and_update(process_map_retweets_table,:hashTag, fn current_value -> {current_value,hashTag} end)
        process_map_retweets_table=Map.merge(process_map_retweets_table,hashTag_1)

        {_,name_of_user_1}=Map.get_and_update(process_map_retweets_table,:name_of_user, fn current_value -> {current_value,client_name} end)
        process_map_retweets_table=Map.merge(process_map_retweets_table,name_of_user_1)

        {_,client_socket_1}=Map.get_and_update(process_map_retweets_table,:client_node_name, fn current_value -> {current_value,socket} end)
        process_map_retweets_table=Map.merge(process_map_retweets_table,client_socket_1)

        {_,reference_1}=Map.get_and_update(process_map_retweets_table,:reference, fn current_value -> {current_value,reference} end)
        process_map_retweets_table=Map.merge(process_map_retweets_table,reference_1)

         {_,original_tweeter_1}=Map.get_and_update(process_map_retweets_table,:original_tweeter, fn current_value -> {current_value,original_tweeter} end)
         process_map_retweets_table=Map.merge(process_map_retweets_table,original_tweeter_1)
        
        :ets.insert(:retweets,{client_name,process_map_retweets_table})

        #########################################################################################

        {_,state_retweets}=Map.get_and_update(state,:number_of_retweets_after, fn current_value -> {current_value,current_value+1} end)
        state=Map.merge(state,state_retweets)

        #Get its subscribed user and send the given retweet 
        is_subscribed_by=get_a_list_of_is_subscribed_by_for_given_client(client_name,state)
        Enum.each(is_subscribed_by,fn({client_name_x,socket_x,value}) -> GenServer.cast({client_name_x},{:retweet,tweet,hashTag,client_name_x,nil,reference,nil,nil,original_tweeter,socket_x,client_name})  end)

        {:noreply,state}
end

def handle_cast({:got_mention_tweet,name_of_user,tweet,hashTag,reference,socket},state) do

        
        # :ets.new(:users, [:bag, :protected, :named_table])
        # :ets.new(:hashTags, [:bag, :protected, :named_table])
        # :ets.new(:tweets, [:bag, :protected, :named_table])
        # :ets.new(:user_mention_tweets, [:bag, :protected, :named_table])
        # :ets.new(:retweets, [:bag, :protected, :named_table])
        # :ets.new(:user_list, [:set, :protected, :named_table])

        #Change Tweets Table

        process_map_tweets_table=%{:tweet => nil, :hashTag => nil, :name_of_user => nil, :socket => nil, :reference => nil,:reference_node=>nil}

        {_,random_tweet_1}=Map.get_and_update(process_map_tweets_table,:tweet, fn current_value -> {current_value,tweet} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,random_tweet_1)

        {_,hashTag_1}=Map.get_and_update(process_map_tweets_table,:hashTag, fn current_value -> {current_value,hashTag} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,hashTag_1)

        {_,name_of_user_1}=Map.get_and_update(process_map_tweets_table,:name_of_user, fn current_value -> {current_value,name_of_user} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,name_of_user_1)

        {_,socket_1}=Map.get_and_update(process_map_tweets_table,:socket, fn current_value -> {current_value,socket} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,socket_1)

        {_,reference_1}=Map.get_and_update(process_map_tweets_table,:reference, fn current_value -> {current_value,reference} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,reference_1)
        
        :ets.insert(:tweets,{name_of_user,process_map_tweets_table})

        #################################################

        #Change only user Mentioned Tweets 

        process_map_user_mentioner_tweets_table=%{:tweet => nil, :hashTag => nil, :name_of_user => nil, :socket => nil, :reference => nil,:reference_node=>nil}

        {_,random_tweet_1}=Map.get_and_update(process_map_user_mentioner_tweets_table,:tweet, fn current_value -> {current_value,tweet} end)
        process_map_user_mentioner_tweets_table=Map.merge(process_map_user_mentioner_tweets_table,random_tweet_1)

        {_,hashTag_1}=Map.get_and_update(process_map_user_mentioner_tweets_table,:hashTag, fn current_value -> {current_value,hashTag} end)
        process_map_user_mentioner_tweets_table=Map.merge(process_map_user_mentioner_tweets_table,hashTag_1)

        {_,name_of_user_1}=Map.get_and_update(process_map_user_mentioner_tweets_table,:name_of_user, fn current_value -> {current_value,name_of_user} end)
        process_map_user_mentioner_tweets_table=Map.merge(process_map_user_mentioner_tweets_table,name_of_user_1)

        {_,client_socket_1}=Map.get_and_update(process_map_user_mentioner_tweets_table,:socket, fn current_value -> {current_value,socket} end)
        process_map_user_mentioner_tweets_table=Map.merge(process_map_user_mentioner_tweets_table,client_socket_1)

        {_,reference_1}=Map.get_and_update(process_map_user_mentioner_tweets_table,:reference, fn current_value -> {current_value,reference} end)
        process_map_user_mentioner_tweets_table=Map.merge(process_map_user_mentioner_tweets_table,reference_1)
        
        :ets.insert(:user_mention_tweets,{reference,process_map_user_mentioner_tweets_table})

        {_,state_tweets}=Map.get_and_update(state,:number_of_tweets_after, fn current_value -> {current_value,current_value+1} end)
        state=Map.merge(state,state_tweets)

        {_,state_hashTag}=Map.get_and_update(state,:hashTag, fn current_value -> {current_value,current_value++[hashTag]} end)
        state=Map.merge(state,state_hashTag)    
          

        client_name=name_of_user

        #Get its subscribed user and send the given tweet
        is_subscribed_by=get_a_list_of_is_subscribed_by_for_given_client(client_name,state)
        Enum.each(is_subscribed_by,fn({client_name_x,socket_x,value}) -> GenServer.cast({client_name_x},{:got_a_tweet,tweet,hashTag,name_of_user,nil,client_name_x,socket_x})  end)

        #Send the mention tweet to user to the reference
        GenServer.cast({reference},{:got_a_tweet_with_mention,reference,nil,name_of_user,nil,tweet,hashTag})

        {:noreply,state}
end

def handle_cast({:add_is_subscribed_for_given_client,random_node_choose,node},state)do

        # :ets.new(:user_list_with_subscription,[:set, :protected, :named_table])


         client_name=elem(random_node_choose,0)
         client_node=elem(random_node_choose,1)

         array_list=:ets.lookup(:users, client_name)
         elem_tuple=Enum.at(array_list,0)
         users_tuple=elem(elem_tuple,1)

         users_tuple_is_subscribed_to=users_tuple[:is_subscribed_by]
         users_tuple_is_subscribed_to=users_tuple_is_subscribed_to++[node]


         #process_map=%{:node_client => nil, :hashTags => [], :password => nil, :has_subscribed_to => [], :is_subscribed_by => [],:name_node => nil, :id => nil, :no_of_zipf_tweets =>0, :probability_of_zipf_functions=>0, :number_of_subscribers=>0 }

         users_tuple_number_of_subscribers=users_tuple[:number_of_subscribers]
         users_tuple_number_of_subscribers=users_tuple_number_of_subscribers+1;
         
         
         {_,state_random_is_subscribed_by}=Map.get_and_update(users_tuple,:is_subscribed_by, fn current_value -> {current_value,users_tuple_is_subscribed_to} end)
         users_tuple=Map.merge(users_tuple,state_random_is_subscribed_by)

         {_,state_number}=Map.get_and_update(users_tuple,:number_of_subscribers, fn current_value -> {current_value,users_tuple_number_of_subscribers} end)
         users_tuple=Map.merge(users_tuple,state_number)

         :ets.delete(:users, client_name)
         :ets.insert(:users, {client_name,users_tuple})

         {:noreply,state}
end

def handle_cast({:assign_hashTags_to_user,numHashTags,element}, state) do
         
        #process_map=%{:node_client => nil, :hashTags => [], :password => nil, :has_subscribed_to => [], :is_subscribed_by => [],:name_node => nil, :id => nil, :no_of_zipf_tweets =>0, :probability_of_zipf_functions=>0, :number_of_subscribers=>0 }


         client_name=elem(element,0)
         client_node=elem(element,1)

         array_list=:ets.lookup(:users, client_name)
         elem_tuple=Enum.at(array_list,0)
         users_tuple=elem(elem_tuple,1)
        #{:ok,%{:start_value=>1,:number_of_tweets_before=>0, :number_of_tweets_after=>0, :number_of_retweets_before=>0,:hashTag=>[]}}


         list_of_preferred_hashtags_for_user=Enum.take_random(state[:hashTag],numHashTags)

         users_tuple_hashTags=users_tuple[:hashTags]
         users_tuple_hashTags=users_tuple_hashTags++list_of_preferred_hashtags_for_user
         
         {_,state_random_hashTags}=Map.get_and_update(users_tuple,:hashTags, fn current_value -> {current_value,users_tuple_hashTags} end)
         users_tuple=Map.merge(users_tuple,state_random_hashTags)

         :ets.delete(:users, client_name)
         :ets.insert(:users, {client_name,users_tuple})
         {:noreply,state}

end

def handle_call({:get_random_tweet_for_mention,client_name,client_node},_from ,state) do

        #Tweet details
        random_tweet_text=Project4Part2.LibFunctions.randomizer(32,:downcase)
        random_hashTag="#"<>Project4Part2.LibFunctions.randomizer(8,true)
        
        #Take a random user not the same user for retweeting

         array_list=:ets.lookup(:user_list, "user_list")
         elem_tuple=Enum.at(array_list,0)
         list=elem(elem_tuple,1)

         #IO.inspect users_array_lis
        random_user_id_for_given_user=Enum.random(list)
       
        node=client_node
        hashTag=random_hashTag
        tweet=random_tweet_text
        tweet_by_user=client_name
        reference=elem(random_user_id_for_given_user,0)
        reference_node=elem(random_user_id_for_given_user,1)

        #tweet=tweet<>" @"<>to_string(reference)

        #GenServer.cast(Boss_Server,{:got_mention_tweet,client_node,client_name,tweet,hashTag,reference,reference_node})

        {:reply,{node,hashTag,tweet,tweet_by_user,reference,reference_node},state}
        #{:noreply,state}
end

def zipf_distribution(client_name,client_node_name,numNodes,list) do


        # :ets.new(:users, [:bag, :protected, :named_table])
        # :ets.new(:hashTags, [:bag, :protected, :named_table])
        # :ets.new(:tweets, [:bag, :protected, :named_table])
        # :ets.new(:user_mention_tweets, [:bag, :protected, :named_table])
        # :ets.new(:retweets, [:bag, :protected, :named_table])
        # :ets.new(:user_list, [:set, :protected, :named_table])

        #  array_list=:ets.lookup(:user_list, "user_list")
        #  elem_tuple=Enum.at(array_list,0)
        #  list=elem(elem_tuple,1)

        #IO.inspect list

        #  process_map=%{:node_client => nil, :hashTags => [], :password => nil, :has_subscribed_to => [], :is_subscribed_by => [],:name_node => nil, :id => nil, :no_of_zipf_tweets =>0, :probability_of_zipf_functions=>0, :number_of_subscribers=>0 }

        array_list=Enum.filter(Enum.sort(Enum.map(Enum.with_index(list),fn({x,i})-> 
        
        user_array_list=:ets.lookup(:users,elem(x,0))
        elem_tuple=Enum.at(user_array_list,0)
        user_tuple=elem(elem_tuple,1)

        #IO.inspect user_tuple

        {user_tuple[:number_of_subscribers],x}end)),& !is_nil(&1))


        array_list=Enum.reverse(array_list)
        #IO.inspect array_list

        #{name_node,node_client,0}

        array_list_final=Enum.filter(Enum.map(Enum.with_index(array_list),fn({x,index})
        -> if(elem(elem(x,1),1)==client_node_name and elem(elem(x,1),0)==client_name) 
        do {elem(x,0),index,elem(elem(x,1),1),elem(elem(x,1),0)} end end),& !is_nil(&1))

        #IO.inspect array_list_final

        number_of_subscribers=elem(Enum.at(array_list_final,0),0)   
        #IO.inspect  number_of_subscribers
        index=elem(Enum.at(array_list_final,0),1)   

        {num_tweets,num_tweets_with_mention,f_x}=zipf_distribution_for_given_x(index+1,numNodes,client_name,client_node_name)

       # IO.puts "#{inspect client_name} #{inspect client_node_name} #{inspect num_tweets+num_tweets_with_mention}"

        #:client_zipf_details_per_client_node
        table=:ets.lookup(:client_zipf_details_per_client_node,client_node_name)

        if(length(table)>0)do
                 user_list=Enum.at(table,0)
                 users_array_list=elem(user_list,1)
                 users_array_list=users_array_list++[{client_node_name,client_name,f_x,num_tweets+num_tweets_with_mention}]
                 :ets.insert(:client_zipf_details_per_client_node,{client_node_name,users_array_list})
        else
                :ets.insert(:client_zipf_details_per_client_node,{client_node_name,[{client_node_name,client_name,f_x,num_tweets+num_tweets_with_mention}]})
        end


        user_array_list=:ets.lookup(:users,client_name)
        user_list=Enum.at(user_array_list,0)
        users_tuple=elem(user_list,1)



          #      process_map=%{:node_client => nil, :hashTags => [], :password => nil, :has_subscribed_to => [], :is_subscribed_by => [],:name_node => nil, :id => nil, :no_of_zipf_tweets =>0, :probability_of_zipf_functions=>0, :number_of_subscribers=>0 }
         
         {_,state_random_is_subscribed_by}=Map.get_and_update(users_tuple,:no_of_zipf_tweets, fn current_value -> {current_value,num_tweets+num_tweets_with_mention} end)
         users_tuple=Map.merge(users_tuple,state_random_is_subscribed_by)

         {_,state_number}=Map.get_and_update(users_tuple,:probability_of_zipf_functions, fn current_value -> {current_value,f_x} end)
         users_tuple=Map.merge(users_tuple,state_number)

         #IO.inspect users_tuple

         :ets.delete(:users, client_name)
         :ets.insert(:users, {client_name,users_tuple})

         #periodic_print_zipf_distribution(client_node_name)
         #{:noreply,state}

end




def zipf_distribution_for_given_x(x,numNodes,client_name,client_node_name)do
        c=:math.pow(Enum.reduce(Enum.to_list(1..numNodes),0,fn(x,acc)->:math.pow(1/x,@s)+acc end),-1)

        f_x=(c/(:math.pow(x,@s)))
        num_tweets=round((@numTweetsForZipf-1)*f_x)
        num_tweets_with_mention=round(f_x)*@numTweetsForZipf

        {num_tweets,num_tweets_with_mention,f_x}
        
end

def start_zipf_distribution()do
         array_list=:ets.lookup(:user_list, "user_list")
         elem_tuple=Enum.at(array_list,0)
         list=elem(elem_tuple,1)

        #{name_node,node_client,0}

        #IO.inspect list


        Enum.each(list, fn(x) -> 
                user_array_list=:ets.lookup(:users,elem(x,0))
                user_list=Enum.at(user_array_list,0)
                user_tuple=elem(user_list,1)

                no_of_zipf_tweets=user_tuple[:no_of_zipf_tweets]
                number_of_subscribers=user_tuple[:number_of_subscribers]
                IO.puts "#{inspect no_of_zipf_tweets} number of tweets for Client #{inspect elem(x,0)} of #{inspect elem(x,1)} has #{inspect number_of_subscribers} subscribers "

                if(no_of_zipf_tweets>0) do 
                        Enum.each(Enum.to_list(1..no_of_zipf_tweets),fn(y) -> GenServer.cast({elem(x,0),elem(x,1)},{:tweet,elem(x,0),elem(x,1),nil})  end)   
                end 
         end)
end


def handle_cast({:query,clientName,socket},state) do

                IO.inspect " I am logged in"
                
                user_array_list=:ets.lookup(:users,clientName)
                user_list=Enum.at(user_array_list,0)
                user_tuple=elem(user_list,1)

                IO.inspect user_tuple

                #IO.inspect state[:hashTag]

                #      process_map=%{:node_client => nil, :hashTags => [], :password => nil, :has_subscribed_to => [], :is_subscribed_by => [],:name_node => nil, :id => nil, :no_of_zipf_tweets =>0, :probability_of_zipf_functions=>0, :number_of_subscribers=>0 }

                #User Subscribed to tweets latest 5
                # process_map_tweets_table=%{:tweet => nil, :hashTag => nil, :name_of_user => nil, :client_node_name => nil, :reference => nil,reference_node=>nil}

                user_is_subscribed_list=user_tuple[:has_subscribed_to]
                #IO.inspect user_is_subscribed_list
                user_subscribed_latest_tweets_5=Enum.map(user_is_subscribed_list,fn(x)-> Enum.take(:ets.lookup(:tweets,elem(x,0)),-10) end)

                #IO.inspect user_subscribed_latest_tweets_5

                #{:got_a_tweet,Enum.at(tweets,x),Enum.at(hashTag,x),Enum.at(tweet_by_user,x),Enum.at(nodes_tweeting,x),nil,Map.get(userTuple,:name_node),Map.get(userTuple,:node_client)
                if(length(user_subscribed_latest_tweets_5)>0) do
                        array_list=Enum.at(user_subscribed_latest_tweets_5,0)
                        #IO.inspect array_list
                        Enum.each(Enum.with_index(array_list),fn({x,i})->
                        x_tuple=x
                        user_process_map=elem(x_tuple,1)
                        #IO.inspect user_process_map
                        GenServer.cast(clientName,{:got_a_tweet,Map.get(user_process_map,:tweet),Map.get(user_process_map,:hashTag),Map.get(user_process_map,:name_of_user),nil,clientName,nil})
                        end)
                end

                #  :ets.new(:users, [:bag, :protected, :named_table])
                # :ets.new(:hashTags, [:bag, :protected, :named_table])
                # :ets.new(:tweets, [:bag, :protected, :named_table])
                # :ets.new(:user_mention_tweets, [:bag, :protected, :named_table])
                # :ets.new(:retweets, [:bag, :protected, :named_table])
                # :ets.new(:user_list, [:set, :protected, :named_table])

                user_is_subscribed_hashTag=user_tuple[:hashTags]
                user_hashTag_latest=Enum.map(user_is_subscribed_hashTag,fn(x)-> Enum.take(:ets.lookup(:hashTags,x),-1) end)

                #IO.inspect user_hashTag_latest

                 if(length(user_hashTag_latest)>0) do
                        array_list=Enum.at(user_hashTag_latest,0)
                        Enum.each(array_list,fn(x)->
                        x_tuple=x
                        user_process_map=elem(x_tuple,1)
                        #    def handle_cast({:got_a_tweet,random_tweet,random_hashtag,original_tweeter,_,client_name_x,_},state) do
                        GenServer.cast({clientName},{:got_a_tweet,Map.get(user_process_map,:tweet),Map.get(user_process_map,:hashTag),Map.get(user_process_map,:name_of_user),nil,clientName,nil})
                        end)
                end

                user_mentioned=:ets.lookup(:user_mention_tweets,clientName)
                user_mentioned_latest=Enum.take(user_mentioned,-5)

                #IO.inspect user_mentioned_latest

                 if(length(user_mentioned_latest)>0) do
                        Enum.each(user_mentioned_latest,fn(x)->
                        user_process_map=elem(x,1)
                        #    def handle_cast({:got_a_tweet,random_tweet,random_hashtag,original_tweeter,_,client_name_x,_},state) do
                         GenServer.cast({clientName},{:got_a_tweet,Map.get(user_process_map,:tweet),Map.get(user_process_map,:hashTag),Map.get(user_process_map,:name_of_user),nil,clientName,nil})
                        end)
                end

                push socket, "print", %{data: "helli"}

        {:noreply,state}
end

 def handle_cast({:update_num_client,numClients}, state) do
         {_,state_numClients}=Map.get_and_update(state,:numClients, fn current_value -> {current_value,numClients} end)
         state=Map.merge(state,state_numClients)
         {:noreply,state}
 end

 def handle_cast({:increment_numClients,value,numNodes,l,fullList},state) do
          {_,state_numClients}=Map.get_and_update(state,:count_numClients, fn current_value -> {current_value,current_value+value} end)
          state=Map.merge(state,state_numClients)

          #IO.inspect l
          #IO.puts "++++++"

        #   array_list=:ets.lookup(:user_list, "user_list")
        #   elem_tuple=Enum.at(array_list,0)
        #   users_array_list1=elem(elem_tuple,1)

        #   users_array_list1=users_array_list1++l

         #{name_of_node,client_node_name,0}
          Enum.each(l,fn({name_of_node,client_node_name,_}) -> zipf_distribution(name_of_node,client_node_name,numNodes,l)  end)
          #Process.sleep(1_0000)

          numClients=Map.get(state, :numClients)
          count_numClients=Map.get(state, :count_numClients)

          #:ets.delete(:user_list,"user_list")
          #:ets.insert(:user_list, {"user_list",users_array_list1})

          IO.inspect "I am here"

          if(numClients == count_numClients)do
                # Handle Zipf here
                IO.puts "Started Zipf"
                start_zipf_distribution()
          end

          {:noreply,state}
 end

end