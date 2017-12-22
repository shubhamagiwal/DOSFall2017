defmodule Project4Part1.Boss do
use GenServer
@numTweetsForZipf 100
@s 1


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

def handle_call({:get_start_value}, _from, state) do
   {:reply,state[:start_value],state}
end

def handle_cast({:update_start_value,newValue},state)do
      {_,state_start_value}=Map.get_and_update(state,:start_value, fn current_value -> {current_value,newValue} end)
      state=Map.merge(state,state_start_value)
      {:noreply,state}
end

def handle_call({:get_list_users},_from,state)do
        array_list=:ets.lookup(:user_list, "user_list")
        elem_tuple=Enum.at(array_list,0)
        list=elem(elem_tuple,1)
        {:reply,list,state} 
end

def handle_cast({:created_user,node_client,password,name_node,id},state)do

      process_map=%{:node_client => nil, :hashTags => [], :password => nil, :has_subscribed_to => [], :is_subscribed_by => [],:name_node => nil, :id => nil, :no_of_zipf_tweets =>0, :probability_of_zipf_functions=>0, :number_of_subscribers=>0 }

      {_,state_name_node}=Map.get_and_update(process_map,:name_node, fn current_value -> {current_value,name_node} end)
      process_map=Map.merge(process_map,state_name_node)

      {_,state_password}=Map.get_and_update(process_map,:password, fn current_value -> {current_value,password} end)
      process_map=Map.merge(process_map,state_password)

      {_,state_node_client}=Map.get_and_update(process_map,:node_client, fn current_value -> {current_value,node_client} end)
      process_map=Map.merge(process_map,state_node_client)

      {_,state_id}=Map.get_and_update(process_map,:id, fn current_value -> {current_value,id} end)
      process_map=Map.merge(process_map,state_id)

      #Update the user_list with the client and node tuple
      #{name_of_node,client_node_name}
        array_list=:ets.lookup(:user_list, "user_list")
        elem_tuple=Enum.at(array_list,0)
        list=elem(elem_tuple,1)
        list=list++[{name_node,node_client,0}]
        :ets.insert(:user_list,{"user_list",list})

        #Added it to the users table
        :ets.insert(:users,{name_node,process_map})

      {:noreply,state}
end

def handle_cast({:got_tweet,random_tweet,random_hashTag,name_of_user,client_node_name,reference,isFreshUser},state)do

        # :ets.new(:users, [:bag, :protected, :named_table])
        # :ets.new(:hashTags, [:bag, :protected, :named_table])
        # :ets.new(:tweets, [:bag, :protected, :named_table])
        # :ets.new(:user_mention_tweets, [:bag, :protected, :named_table])
        # :ets.new(:retweets, [:bag, :protected, :named_table])
        # :ets.new(:user_list, [:set, :protected, :named_table])

        #Change Tweets Table

        #IO.inspect random_tweet

        process_map_tweets_table=%{:tweet => nil, :hashTag => nil, :name_of_user => nil, :client_node_name => nil, :reference => nil,:reference_node=>nil}

        {_,random_tweet_1}=Map.get_and_update(process_map_tweets_table,:tweet, fn current_value -> {current_value,random_tweet} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,random_tweet_1)

        {_,hashTag_1}=Map.get_and_update(process_map_tweets_table,:hashTag, fn current_value -> {current_value,random_hashTag} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,hashTag_1)

        {_,name_of_user_1}=Map.get_and_update(process_map_tweets_table,:name_of_user, fn current_value -> {current_value,name_of_user} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,name_of_user_1)

        {_,client_node_name_1}=Map.get_and_update(process_map_tweets_table,:client_node_name, fn current_value -> {current_value,client_node_name} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,client_node_name_1)

        {_,reference_1}=Map.get_and_update(process_map_tweets_table,:reference, fn current_value -> {current_value,reference} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,reference_1)
        
        :ets.insert(:tweets,{name_of_user,process_map_tweets_table})

        #################################################

        #Change only HashTags 

        process_map_hashTag_table=%{:tweet => nil, :hashTag => nil, :name_of_user => nil, :client_node_name => nil, :reference => nil,:reference_node=>nil}

        {_,random_tweet_1}=Map.get_and_update(process_map_hashTag_table,:tweet, fn current_value -> {current_value,random_tweet} end)
        process_map_hashTag_table=Map.merge(process_map_hashTag_table,random_tweet_1)

        {_,hashTag_1}=Map.get_and_update(process_map_hashTag_table,:hashTag, fn current_value -> {current_value,random_hashTag} end)
        process_map_hashTag_table=Map.merge(process_map_hashTag_table,hashTag_1)

        {_,name_of_user_1}=Map.get_and_update(process_map_hashTag_table,:name_of_user, fn current_value -> {current_value,name_of_user} end)
        process_map_hashTag_table=Map.merge(process_map_hashTag_table,name_of_user_1)

        {_,client_node_name_1}=Map.get_and_update(process_map_hashTag_table,:client_node_name, fn current_value -> {current_value,client_node_name} end)
        process_map_hashTag_table=Map.merge(process_map_hashTag_table,client_node_name_1)

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
        client_node=client_node_name


        # Find the is subscribed user for the given client

        #Format of the output
        #[tweeter@user1: :"localhost-20@10.3.6.63",
        # tweeter@user2: :"localhost-20@10.3.6.63",
        # tweeter@user3: :"localhost-20@10.3.6.63",
        # tweeter@user6: :"localhost-20@10.3.6.63",
        # tweeter@user9: :"localhost-20@10.3.6.63"]
        #IO.inspect isFreshUser
        if(isFreshUser!=true) do
           is_subscribed_by=get_a_list_of_is_subscribed_by_for_given_client(client_name,client_node,state)
           #{:got_a_tweet,random_tweet,random_hashtag,name_of_user,client_node_name,_,client_name_x,client_node_name_x}
           Enum.each(is_subscribed_by,fn({client_name_x,client_node_name_x,y}) -> GenServer.cast({client_name_x,client_node_name_x},{:got_a_tweet,random_tweet,random_hashTag,name_of_user,client_node_name,reference,client_name_x,client_node_name_x})  end)
        end 

        {:noreply,state}
end

def get_a_list_of_is_subscribed_by_for_given_client(client_name,client_node,state) do
        #index=Enum.find_index(state[:users], fn(x) -> x[:node_client] == client_node and x[:name_node]== client_name end)
        array_list=:ets.lookup(:users,client_name)
        elem_tuple=Enum.at(array_list,0)
        users_tuple=elem(elem_tuple,1)
        is_subscribed_by=users_tuple[:is_subscribed_by]
        #IO.inspect is_subscribed_by
        #IO.inspect is_subscribed_by

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

def handle_cast({:got_retweet,client_node_name,name_of_user,tweet,hashTag,reference,reference_node},state) do

        # :ets.new(:users, [:bag, :protected, :named_table])
        # :ets.new(:hashTags, [:bag, :protected, :named_table])
        # :ets.new(:tweets, [:bag, :protected, :named_table])
        # :ets.new(:user_mention_tweets, [:bag, :protected, :named_table])
        # :ets.new(:retweets, [:bag, :protected, :named_table])
        # :ets.new(:user_list, [:set, :protected, :named_table])

       #Change Tweets Table

        process_map_tweets_table=%{:tweet => nil, :hashTag => nil, :name_of_user => nil, :client_node_name => nil, :reference => nil,reference_node=>nil}

        {_,random_tweet_1}=Map.get_and_update(process_map_tweets_table,:tweet, fn current_value -> {current_value,tweet} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,random_tweet_1)

        {_,hashTag_1}=Map.get_and_update(process_map_tweets_table,:hashTag, fn current_value -> {current_value,hashTag} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,hashTag_1)

        {_,name_of_user_1}=Map.get_and_update(process_map_tweets_table,:name_of_user, fn current_value -> {current_value,name_of_user} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,name_of_user_1)

        {_,client_node_name_1}=Map.get_and_update(process_map_tweets_table,:client_node_name, fn current_value -> {current_value,client_node_name} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,client_node_name_1)

        {_,reference_1}=Map.get_and_update(process_map_tweets_table,:reference, fn current_value -> {current_value,reference} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,reference_1)

        {_,reference_node_1}=Map.get_and_update(process_map_tweets_table,:reference, fn current_value -> {current_value,reference_node} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,reference_node_1)
        
        :ets.insert(:tweets,{name_of_user,process_map_tweets_table})

        ############################################################################

        #Change only Retweets Table 

        process_map_retweets_table=%{:tweet => nil, :hashTag => nil, :name_of_user => nil, :client_node_name => nil, :reference => nil,:reference_node=>nil}

        {_,random_tweet_1}=Map.get_and_update(process_map_retweets_table,:tweet, fn current_value -> {current_value,tweet} end)
        process_map_retweets_table=Map.merge(process_map_retweets_table,random_tweet_1)

        {_,hashTag_1}=Map.get_and_update(process_map_retweets_table,:hashTag, fn current_value -> {current_value,hashTag} end)
        process_map_retweets_table=Map.merge(process_map_retweets_table,hashTag_1)

        {_,name_of_user_1}=Map.get_and_update(process_map_retweets_table,:name_of_user, fn current_value -> {current_value,name_of_user} end)
        process_map_retweets_table=Map.merge(process_map_retweets_table,name_of_user_1)

        {_,client_node_name_1}=Map.get_and_update(process_map_retweets_table,:client_node_name, fn current_value -> {current_value,client_node_name} end)
        process_map_retweets_table=Map.merge(process_map_retweets_table,client_node_name_1)

        {_,reference_1}=Map.get_and_update(process_map_retweets_table,:reference, fn current_value -> {current_value,reference} end)
        process_map_retweets_table=Map.merge(process_map_retweets_table,reference_1)

        {_,reference_node_1}=Map.get_and_update(process_map_retweets_table,:reference, fn current_value -> {current_value,reference_node} end)
        process_map_retweets_table=Map.merge(process_map_retweets_table,reference_node_1)
        
        :ets.insert(:retweets,{name_of_user,process_map_retweets_table})

        #########################################################################################

        {_,state_retweets}=Map.get_and_update(state,:number_of_retweets_after, fn current_value -> {current_value,current_value+1} end)
        state=Map.merge(state,state_retweets)

        client_name=name_of_user
        client_node=client_node_name

        #Get its subscribed user and send the given retweet 
        is_subscribed_by=get_a_list_of_is_subscribed_by_for_given_client(client_name,client_node,state)
        Enum.each(is_subscribed_by,fn({client_name_x,client_node_name_x,_}) -> GenServer.cast({client_name_x,client_node_name_x},{:retweet,tweet,hashTag,client_name_x,client_node_name_x,reference,reference_node,client_node_name,name_of_user})  end)

        {:noreply,state}
end

def handle_cast({:got_mention_tweet,client_node_name,name_of_user,tweet,hashTag,reference,reference_node},state) do

        
        # :ets.new(:users, [:bag, :protected, :named_table])
        # :ets.new(:hashTags, [:bag, :protected, :named_table])
        # :ets.new(:tweets, [:bag, :protected, :named_table])
        # :ets.new(:user_mention_tweets, [:bag, :protected, :named_table])
        # :ets.new(:retweets, [:bag, :protected, :named_table])
        # :ets.new(:user_list, [:set, :protected, :named_table])

        #Change Tweets Table

        process_map_tweets_table=%{:tweet => nil, :hashTag => nil, :name_of_user => nil, :client_node_name => nil, :reference => nil,reference_node=>nil}

        {_,random_tweet_1}=Map.get_and_update(process_map_tweets_table,:tweet, fn current_value -> {current_value,tweet} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,random_tweet_1)

        {_,hashTag_1}=Map.get_and_update(process_map_tweets_table,:hashTag, fn current_value -> {current_value,hashTag} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,hashTag_1)

        {_,name_of_user_1}=Map.get_and_update(process_map_tweets_table,:name_of_user, fn current_value -> {current_value,name_of_user} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,name_of_user_1)

        {_,client_node_name_1}=Map.get_and_update(process_map_tweets_table,:client_node_name, fn current_value -> {current_value,client_node_name} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,client_node_name_1)

        {_,reference_1}=Map.get_and_update(process_map_tweets_table,:reference, fn current_value -> {current_value,reference} end)
        process_map_tweets_table=Map.merge(process_map_tweets_table,reference_1)
        
        :ets.insert(:tweets,{name_of_user,process_map_tweets_table})

        #################################################

        #Change only user Mentioned Tweets 

        process_map_user_mentioner_tweets_table=%{:tweet => nil, :hashTag => nil, :name_of_user => nil, :client_node_name => nil, :reference => nil,:reference_node=>nil}

        {_,random_tweet_1}=Map.get_and_update(process_map_user_mentioner_tweets_table,:tweet, fn current_value -> {current_value,tweet} end)
        process_map_user_mentioner_tweets_table=Map.merge(process_map_user_mentioner_tweets_table,random_tweet_1)

        {_,hashTag_1}=Map.get_and_update(process_map_user_mentioner_tweets_table,:hashTag, fn current_value -> {current_value,hashTag} end)
        process_map_user_mentioner_tweets_table=Map.merge(process_map_user_mentioner_tweets_table,hashTag_1)

        {_,name_of_user_1}=Map.get_and_update(process_map_user_mentioner_tweets_table,:name_of_user, fn current_value -> {current_value,name_of_user} end)
        process_map_user_mentioner_tweets_table=Map.merge(process_map_user_mentioner_tweets_table,name_of_user_1)

        {_,client_node_name_1}=Map.get_and_update(process_map_user_mentioner_tweets_table,:client_node_name, fn current_value -> {current_value,client_node_name} end)
        process_map_user_mentioner_tweets_table=Map.merge(process_map_user_mentioner_tweets_table,client_node_name_1)

        {_,reference_1}=Map.get_and_update(process_map_user_mentioner_tweets_table,:reference, fn current_value -> {current_value,reference} end)
        process_map_user_mentioner_tweets_table=Map.merge(process_map_user_mentioner_tweets_table,reference_1)

         {_,reference_node_1}=Map.get_and_update(process_map_user_mentioner_tweets_table,:reference_node, fn current_value -> {current_value,reference_node} end)
        process_map_user_mentioner_tweets_table=Map.merge(process_map_user_mentioner_tweets_table,reference_node_1)
        
        :ets.insert(:user_mention_tweets,{reference,process_map_user_mentioner_tweets_table})

        {_,state_tweets}=Map.get_and_update(state,:number_of_tweets_after, fn current_value -> {current_value,current_value+1} end)
        state=Map.merge(state,state_tweets)

        {_,state_hashTag}=Map.get_and_update(state,:hashTag, fn current_value -> {current_value,current_value++[hashTag]} end)
        state=Map.merge(state,state_hashTag)    
          

        client_name=name_of_user
        client_node=client_node_name

        #Get its subscribed user and send the given tweet
        is_subscribed_by=get_a_list_of_is_subscribed_by_for_given_client(client_name,client_node,state)
        Enum.each(is_subscribed_by,fn({client_name_x,client_node_name_x,_}) -> GenServer.cast({client_name_x,client_node_name_x},{:got_a_tweet,tweet,hashTag,name_of_user,client_node_name,reference,client_name_x,client_node_name_x})  end)

        #Send the mention tweet to user to the reference
        GenServer.cast({reference,reference_node},{:got_a_tweet_with_mention,reference,reference_node,name_of_user,client_node_name,tweet,hashTag})

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

        #  array_list=:ets.lookup(:user_list, "user_list")
        #  elem_tuple=Enum.at(array_list,0)
        #  list=elem(elem_tuple,1)

        #  new_user_list=Enum.map(list,fn(x)-> 
        #         if(elem(x,0)==client_name and elem(x,1)==client_node) do 
        #                 value=elem(x,2)
        #                 value=value+1
        #                 {elem(x,0),elem(x,1),value}
        #         else
        #                 x
        #   end end)

        #   :ets.delete(:user_list, "user_list")
        #   :ets.insert(:user_list, {"user_list",new_user_list})

         #      process_map=%{:node_client => nil, :hashTags => [], :password => nil, :has_subscribed_to => [], :is_subscribed_by => [],:name_node => nil, :id => nil, :no_of_zipf_tweets =>0, :probability_of_zipf_functions=>0, :number_of_subscribers=>0 }

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
        random_tweet_text=Project4Part1.LibFunctions.randomizer(32,:downcase)
        random_hashTag="#"<>Project4Part1.LibFunctions.randomizer(8,true)
        
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


def handle_cast({:query,clientNode,clientName},state) do
                
                user_array_list=:ets.lookup(:users,clientName)
                user_list=Enum.at(user_array_list,0)
                user_tuple=elem(user_list,1)

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
                        GenServer.cast({clientName,clientNode},{:got_a_tweet,Map.get(user_process_map,:tweet),Map.get(user_process_map,:hashTag),Map.get(user_process_map,:name_of_user),Map.get(user_process_map,:client_node_name),nil,clientName,clientNode})
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
                        GenServer.cast({clientName,clientNode},{:got_a_tweet,Map.get(user_process_map,:tweet),Map.get(user_process_map,:hashTag),Map.get(user_process_map,:name_of_user),Map.get(user_process_map,:client_node_name),nil,clientName,clientNode})
                        end)
                end

                user_mentioned=:ets.lookup(:user_mention_tweets,clientName)
                user_mentioned_latest=Enum.take(user_mentioned,-5)

                #IO.inspect user_mentioned_latest

                 if(length(user_mentioned_latest)>0) do
                        Enum.each(user_mentioned_latest,fn(x)->
                        user_process_map=elem(x,1)
                        #IO.inspect user_process_map
                        GenServer.cast({clientName,clientNode},{:got_a_tweet,Map.get(user_process_map,:tweet),Map.get(user_process_map,:hashTag),Map.get(user_process_map,:name_of_user),Map.get(user_process_map,:client_node_name),nil,clientName,clientNode})
                        end)
                end

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
 

 def start_boss(server_tuple) do
        serverName=String.to_atom(to_string("server@")<>elem(server_tuple,0))
        args=elem(server_tuple,1)
        numClients=String.to_integer(Enum.at(args,1))
        {:ok,_}=Node.start(serverName)
        cookie=Application.get_env(:project3, :cookie)
        {:ok,_} = GenServer.start_link(__MODULE__, :ok, name: Boss_Server)  # -> Created the boss process
        GenServer.cast({Boss_Server,serverName},{:update_num_client,numClients})
        Node.set_cookie(cookie)
        :global.register_name(:boss_server,self())
        IO.inspect Node.self()
 end

end