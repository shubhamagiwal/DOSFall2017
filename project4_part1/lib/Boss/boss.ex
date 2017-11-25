defmodule Project4Part1.Boss do
use GenServer
@numTweetsForZipf 100
@s 1


def init(:ok) do
        {:ok,%{:nodes => [],:hashTag => [],:tweets=>[],:reference=>[],:tweet_by_user => [],:users=>[],:reference_node=>[],:start_value=>1}}
end

def handle_call({:get_start_value}, _from, state) do
   {:reply,state[:start_value],state}
end

def handle_cast({:update_start_value,newValue},state)do
      {_,state_password}=Map.get_and_update(state,:start_value, fn current_value -> {current_value,newValue} end)
      state=Map.merge(state,state_password)
      {:noreply,state}
end

def handle_cast({:created_user,node_client,password,name_node,id},state)do

      process_map=%{:node_client => nil, :hashTags => [], :password => nil, :has_subscribed_to => [], :is_subscribed_by => [],:name_node => nil, :id => nil}

      {_,state_name_node}=Map.get_and_update(process_map,:name_node, fn current_value -> {current_value,name_node} end)
      process_map=Map.merge(process_map,state_name_node)

      {_,state_password}=Map.get_and_update(process_map,:password, fn current_value -> {current_value,password} end)
      process_map=Map.merge(process_map,state_password)

      {_,state_node_client}=Map.get_and_update(process_map,:node_client, fn current_value -> {current_value,node_client} end)
      process_map=Map.merge(process_map,state_node_client)

      {_,state_id}=Map.get_and_update(process_map,:id, fn current_value -> {current_value,id} end)
      process_map=Map.merge(process_map,state_id)
      
      {_,state_random_tweet}=Map.get_and_update(state,:users, fn current_value -> {current_value,current_value++[process_map]} end)
      state=Map.merge(state,state_random_tweet)

      {:noreply,state}
end

def handle_cast({:got_tweet,random_tweet,random_hashTag,name_of_user,client_node_name,reference,isFreshUser},state)do

        # tweeter_user_state=Enum.at(state[:tweet_user],tweeter_id-1)
        {_,state_random_tweet}=Map.get_and_update(state,:tweets, fn current_value -> {current_value,current_value++[random_tweet]} end)
        state=Map.merge(state,state_random_tweet)

        {_,state_random_hashTag}=Map.get_and_update(state,:hashTag, fn current_value -> {current_value,current_value++[random_hashTag]} end)
        state=Map.merge(state,state_random_hashTag)

        {_,state_random_reference}=Map.get_and_update(state,:reference, fn current_value -> {current_value,current_value++[reference]} end)
        state=Map.merge(state,state_random_reference)

        {_,state_random_node}=Map.get_and_update(state,:nodes, fn current_value -> {current_value,current_value++[client_node_name]} end)
        state=Map.merge(state,state_random_node)

        {_,state_random_tweeted_user}=Map.get_and_update(state,:tweet_by_user, fn current_value -> {current_value,current_value++[name_of_user]} end)
        state=Map.merge(state,state_random_tweeted_user)

        {_,state_random_tweeted_user}=Map.get_and_update(state,:reference_node, fn current_value -> {current_value,current_value++[nil]} end)
        state=Map.merge(state,state_random_tweeted_user)

        #IO.inspect state

        client_name=name_of_user
        client_node=client_node_name


        # Find the is subscribed user for the given client
        # index=Enum.find_index(state[:users], fn(x) -> x[:node_client] == client_node and x[:name_node]== client_name end)
        # process_map=Enum.at(state[:users],index)
        # is_subscribed_by=process_map[:is_subscribed_by]

        #Format of the output
        #[tweeter@user1: :"localhost-20@10.3.6.63",
        # tweeter@user2: :"localhost-20@10.3.6.63",
        # tweeter@user3: :"localhost-20@10.3.6.63",
        # tweeter@user6: :"localhost-20@10.3.6.63",
        # tweeter@user9: :"localhost-20@10.3.6.63"]
        if(isFreshUser!=true) do
           is_subscribed_by=get_a_list_of_is_subscribed_by_for_given_client(client_name,client_node,state)
           Enum.each(is_subscribed_by,fn({client_name_x,client_node_name_x}) -> GenServer.cast({client_name_x,client_node_name_x},{:got_a_tweet,random_tweet,random_hashTag,name_of_user,client_node_name,reference,client_name_x,client_node_name_x})  end)
        end 

        {:noreply,state}
end

def get_a_list_of_is_subscribed_by_for_given_client(client_name,client_node,state) do
        index=Enum.find_index(state[:users], fn(x) -> x[:node_client] == client_node and x[:name_node]== client_name end)
        process_map=Enum.at(state[:users],index)
        is_subscribed_by=process_map[:is_subscribed_by]
        is_subscribed_by
end

def handle_cast({:add_subscription_for_given_client_user,random_node_choose,node},state)do
         # process_map=%{:node_client => nil, :hashTags => [], :password => nil, :has_subscribed_to => [], :is_subscribed_by => [],:name_node => nil, :id => nil}
         client_name=elem(node,0)
         client_node=elem(node,1)

         index=Enum.find_index(state[:users], fn(x) -> x[:node_client] == client_node and x[:name_node]== client_name end)
         process_map=Enum.at(state[:users],index)
        
         {_,state_random_has_subscribed_to}=Map.get_and_update(process_map,:has_subscribed_to, fn current_value -> {current_value,current_value++[random_node_choose]} end)
         process_map=Map.merge(process_map,state_random_has_subscribed_to)

         {_,state_update_list}=Map.get_and_update(state,:users, fn current_value -> {current_value,List.replace_at(state[:users],index,process_map)} end)
         state=Map.merge(state,state_update_list)

         {:noreply,state}
end

def handle_cast({:got_retweet,client_node_name,name_of_user,tweet,hashTag,reference,reference_node},state) do

        # {:ok,%{:nodes => [],:hashTag => [],:tweets=>[],:reference=>[],:tweet_by_user => [],:users=>[]}}

        {_,state_random_node}=Map.get_and_update(state,:nodes, fn current_value -> {current_value,current_value++[client_node_name]} end)
        state=Map.merge(state,state_random_node)

        {_,state_random_hashTag}=Map.get_and_update(state,:hashTag, fn current_value -> {current_value,current_value++[hashTag]} end)
        state=Map.merge(state,state_random_hashTag)
        
        {_,state_random_tweet}=Map.get_and_update(state,:tweets, fn current_value -> {current_value,current_value++[tweet]} end)
        state=Map.merge(state,state_random_tweet)

        {_,state_random_tweet_user}=Map.get_and_update(state,:tweet_by_user, fn current_value -> {current_value,current_value++[name_of_user]} end)
        state=Map.merge(state,state_random_tweet_user)

        {_,state_random_tweet_user}=Map.get_and_update(state,:reference, fn current_value -> {current_value,current_value++[reference]} end)
        state=Map.merge(state,state_random_tweet_user)

        {_,state_random_tweet_user}=Map.get_and_update(state,:reference_node, fn current_value -> {current_value,current_value++[reference_node]} end)
        state=Map.merge(state,state_random_tweet_user)

        client_name=name_of_user
        client_node=client_node_name

        #Get its subscribed user and send the given tweet 
        #random_tweet,random_hashtag,name_of_user,client_node_name,reference,reference_node
        #client_node_name,name_of_user,tweet,hashTag,reference,reference_node
        #client_node_name,name_of_user
        is_subscribed_by=get_a_list_of_is_subscribed_by_for_given_client(client_name,client_node,state)
        Enum.each(is_subscribed_by,fn({client_name_x,client_node_name_x}) -> GenServer.cast({client_name_x,client_node_name_x},{:retweet,tweet,hashTag,client_name_x,client_node_name_x,nil,nil,client_node_name,name_of_user})  end)

        {:noreply,state}
end

def handle_cast({:got_mention_tweet,client_node_name,name_of_user,tweet,hashTag,reference,reference_node},state) do

        # {:ok,%{:nodes => [],:hashTag => [],:tweets=>[],:reference=>[],:tweet_by_user => [],:users=>[]}}

        {_,state_random_node}=Map.get_and_update(state,:nodes, fn current_value -> {current_value,current_value++[client_node_name]} end)
        state=Map.merge(state,state_random_node)

        {_,state_random_hashTag}=Map.get_and_update(state,:hashTag, fn current_value -> {current_value,current_value++[hashTag]} end)
        state=Map.merge(state,state_random_hashTag)
        
        {_,state_random_tweet}=Map.get_and_update(state,:tweets, fn current_value -> {current_value,current_value++[tweet]} end)
        state=Map.merge(state,state_random_tweet)

        {_,state_random_tweet_user}=Map.get_and_update(state,:tweet_by_user, fn current_value -> {current_value,current_value++[name_of_user]} end)
        state=Map.merge(state,state_random_tweet_user)

        {_,state_random_tweet_user}=Map.get_and_update(state,:reference, fn current_value -> {current_value,current_value++[reference]} end)
        state=Map.merge(state,state_random_tweet_user)

        {_,state_random_tweet_user}=Map.get_and_update(state,:reference_node, fn current_value -> {current_value,current_value++[reference_node]} end)
        state=Map.merge(state,state_random_tweet_user)

        client_name=name_of_user
        client_node=client_node_name

        #Get its subscribed user and send the given tweet
        is_subscribed_by=get_a_list_of_is_subscribed_by_for_given_client(client_name,client_node,state)
        Enum.each(is_subscribed_by,fn({client_name_x,client_node_name_x}) -> GenServer.cast({client_name_x,client_node_name_x},{:got_a_tweet,tweet,hashTag,name_of_user,client_node_name,reference,client_name_x,client_node_name_x})  end)

        #Send the mention tweet to user to the reference
        GenServer.cast({reference,reference_node},{:got_a_tweet_with_mention,reference,reference_node,name_of_user,client_node_name,tweet,hashTag})

        {:noreply,state}
end

def handle_cast({:add_is_subscribed_for_given_client,random_node_choose,node},state)do
         # process_map=%{:node_client => nil, :hashTags => [], :password => nil, :has_subscribed_to => [], :is_subscribed_by => [],:name_node => nil, :id => nil}
         client_name=elem(random_node_choose,0)
         client_node=elem(random_node_choose,1)

         index=Enum.find_index(state[:users], fn(x) -> x[:node_client] == client_node and x[:name_node]== client_name end)
         process_map=Enum.at(state[:users],index)
        
         {_,state_random_has_subscribed_to}=Map.get_and_update(process_map,:is_subscribed_by, fn current_value -> {current_value,current_value++[node]} end)
         process_map=Map.merge(process_map,state_random_has_subscribed_to)

         {_,state_update_list}=Map.get_and_update(state,:users, fn current_value -> {current_value,List.replace_at(state[:users],index,process_map)} end)
         state=Map.merge(state,state_update_list)

         {:noreply,state}
end

def handle_cast({:assign_hashTags_to_user,numHashTags,element}, state) do
         
         #IO.inspect element
         client_name=elem(element,0)
         client_node=elem(element,1)

         index=Enum.find_index(state[:users], fn(x) -> x[:node_client] == client_node and x[:name_node]== client_name end)
         
         process_map=Enum.at(state[:users],index)

         list_of_preferred_hashtags_for_user=Enum.take_random(state[:hashTag],numHashTags)

         {_,state_random_hashTags}=Map.get_and_update(process_map,:hashTags, fn current_value -> {current_value,current_value++list_of_preferred_hashtags_for_user} end)
         process_map=Map.merge(process_map,state_random_hashTags)

         {_,state_update_list}=Map.get_and_update(state,:users, fn current_value -> {current_value,List.replace_at(state[:users],index,process_map)} end)
         state=Map.merge(state,state_update_list)

         {:noreply,state}

end

def handle_call({:get_random_tweet_for_mention,client_name,client_node}, _from, state) do
        # {:ok,%{:nodes => [],:hashTag => [],:tweets=>[],:reference=>[],:tweet_by_user => [],:users=>[],:reference_node=>[]}}
        #client_tweet_ids_array=Enum.filter(Enum.with_index(Enum.map(Enum.map(Enum.with_index(state[:tweets]),fn({_,i}) ->
        #        if(    Enum.at(state[:nodes],i)== client_node 
        #           and Enum.at(state[:tweet_by_user],i)== client_name 
        #            and Enum.at(state[:reference_node],i)== nil ) do
        #                i
        #        end end),fn(x)-> is_nil(x) end)), fn({x,i}) -> if(x==false) do i end end)

        #random_tweet_id_for_given_user=elem(Enum.random(client_tweet_ids_array),1)

        #Tweet details
        random_tweet_text=Project4Part1.LibFunctions.randomizer(32,:downcase)
        random_hashTag="#"<>Project4Part1.LibFunctions.randomizer(8,true)
        
        #Take a random user not the same user for retweeting
        #process_map=%{:node_client => nil, :hashTags => [], :password => nil, :has_subscribed_to => [], :is_subscribed_by => [],:name_node => nil, :id => nil}

        user_array_ids=Enum.filter(Enum.map(Enum.with_index(state[:users]),fn({x,i}) ->
                if(x[:name_node]!= client_name ) do
                        i
                end end), & !is_nil(&1))
        
        random_user_id_for_given_user=Enum.random(user_array_ids)
        random_user_map_from_id=Enum.at(state[:users],random_user_id_for_given_user)

        node=client_node
        hashTag=random_hashTag
        tweet=random_tweet_text
        tweet_by_user=client_name
        reference=random_user_map_from_id[:name_node]
        reference_node=random_user_map_from_id[:node_client]

        {:reply,{node,hashTag,tweet,tweet_by_user,reference,reference_node},state}
end

def handle_cast({:zipf_distribution,client_name,client_node_name,numNodes},state) do

        array_list=Enum.filter(Enum.sort(Enum.map(Enum.with_index(state[:users]),fn({x,i})-> 
        {Enum.count(x[:is_subscribed_by]),i,x}end)),& !is_nil(&1))

        array_list_final=Enum.filter(Enum.map(Enum.with_index(array_list),fn({x,index})
        -> if(elem(x,2)[:node_client]==client_node_name and elem(x,2)[:name_node]==client_name) 
        do {elem(x,0),index} end end),& !is_nil(&1))

        number_of_subscribers=elem(Enum.at(array_list_final,0),0)    
        index=elem(Enum.at(array_list_final,0),1)   

        zipf_distribution_for_given_x(index+1,numNodes,client_name,client_node_name)

        {:noreply,state}

end

def zipf_distribution_for_given_x(x,numNodes,client_name,client_node_name)do
        c=:math.pow(Enum.reduce(Enum.to_list(1..numNodes),0,fn(x,acc)->:math.pow(1/x,@s)+acc end),-1)
        #IO.inspect :math.pow(x,@s)

        f_x=(c/(:math.pow(x,@s)))
        num_tweets=round((@numTweetsForZipf-1)*f_x)
        num_tweets_with_mention=round(f_x)

        #IO.inspect num_tweets
        #IO.inspect num_tweets_with_mention

        #    def handle_cast({:tweet,name_of_user,client_node_name,reference},state)do
        # IO.inspect "I am in Zipf"

        if(num_tweets>0)do
                Enum.each(Enum.to_list(1..num_tweets),fn(x) -> GenServer.cast({client_name,client_node_name},{:tweet,client_name,client_node_name,nil})  end)      
        end

         #       def handle_cast({:mention_tweet,client_node_name,name_of_user},state)do

        if(num_tweets_with_mention>0)do
                Enum.each(Enum.to_list(1..num_tweets_with_mention),fn(x) -> GenServer.cast({client_name,client_node_name},{:mention_tweet,client_node_name,client_name}) end)      
        end
        
end

def handle_cast({:query,clientNode,clientName},state) do
    list=Enum.filter(Enum.with_index(state[:users]), fn({x,i}) -> if(x[:node_client]==clientNode and x[:name_node]==clientName) do  i  end end)
    
    if(length(list)>0) do
        login_query_for_client(state,elem(Enum.at(list,0),1))   
    end
    {:noreply,state}
end

def login_query_for_client(state,index)do
     userTuple=Enum.at(state[:users],index)
    
     tweets=state[:tweets]
     hashTag=state[:hashTag]
     reference=state[:reference]
     tweet_by_user=state[:tweet_by_user]
     user_preferred_hashtags=userTuple[:hashTags]
     user_has_subscibed_to_list=userTuple[:has_subscribed_to]
     nodes_tweeting=state[:nodes]

     # User Preferred Tag Tweets
     hashTags_indices_for_user_preferred_tags=Enum.filter(Enum.map(user_preferred_hashtags,fn(x)-> Enum.find_index(hashTag,fn(y) -> x==y  end)  end), & !is_nil(&1))
     if(length(hashTags_indices_for_user_preferred_tags)>0) do
        #tweets_based_user_preferred_hashTags=Enum.map(hashTags_indices_for_user_preferred_tags,fn(x)-> to_string(Enum.at(tweets,x))<>" By user "<>to_string(Enum.at(tweet_by_user,x)) end) 
        #random_tweet,random_hashtag,name_of_user,client_node_name,_,client_name_x,client_node_name_x
        Enum.each(hashTags_indices_for_user_preferred_tags,fn(x)->
                GenServer.cast({Map.get(userTuple,:name_node),Map.get(userTuple,:node_client)},{:got_a_tweet,Enum.at(tweets,x),Enum.at(hashTag,x),Enum.at(tweet_by_user,x),Enum.at(nodes_tweeting,x),nil,Map.get(userTuple,:name_node),Map.get(userTuple,:node_client)})
        end)
        #GenServer.cast({Map.get(userTuple,:name_node),Map.get(userTuple,:node_client)},{:here,tweets_based_user_preferred_hashTags})
     else
        tweets_based_user_preferred_hashTags=[]
     end 

     # User Referred in Tweets
     references_indices_where_user_is_mentioned=Enum.filter(Enum.map(Enum.with_index(reference),fn({x,i})-> 
                if(x==Map.get(userTuple,:name_node)) do i end end),& !is_nil(&1))

      if(length(references_indices_where_user_is_mentioned)>0) do
        #tweets_based_references_for_given_user=Enum.map(references_indices_where_user_is_mentioned,fn(x)-> to_string(Enum.at(tweets,x))<>" By user "<>to_string(Enum.at(tweet_by_user,x)) end) 
        #GenServer.cast({Map.get(userTuple,:name_node),Map.get(userTuple,:node_client)},{:here,tweets_based_references_for_given_user})
        Enum.each(references_indices_where_user_is_mentioned,fn(x)->
                GenServer.cast({Map.get(userTuple,:name_node),Map.get(userTuple,:node_client)},{:got_a_tweet,Enum.at(tweets,x),Enum.at(hashTag,x),Enum.at(tweet_by_user,x),Enum.at(nodes_tweeting,x),nil,Map.get(userTuple,:name_node),Map.get(userTuple,:node_client)})
        end)
      else
        tweets_based_references_for_given_user=[]
      end

     # User has Subscribed to Tweets
       nodes_id_for_tweets=Enum.map(Enum.filter(Enum.with_index(Enum.map(Enum.with_index(tweet_by_user),fn({x,i})-> Enum.find_index(user_has_subscibed_to_list,fn(y)-> x==elem(y,0) end) end)),fn({x,i})-> x end),fn({x,i})-> i end)
       
       if(length(nodes_id_for_tweets)>0) do
        #tweets_based_has_subscribed_to_for_given_user=Enum.map(nodes_id_for_tweets,fn(x)-> to_string(Enum.at(tweets,x))<>" By user "<>to_string(Enum.at(tweet_by_user,x)) end) 
        #GenServer.cast({Map.get(userTuple,:name_node),Map.get(userTuple,:node_client)},{:here,tweets_based_has_subscribed_to_for_given_user})
        Enum.each(nodes_id_for_tweets,fn(x)->
                GenServer.cast({Map.get(userTuple,:name_node),Map.get(userTuple,:node_client)},{:got_a_tweet,Enum.at(tweets,x),Enum.at(hashTag,x),Enum.at(tweet_by_user,x),Enum.at(nodes_tweeting,x),nil,Map.get(userTuple,:name_node),Map.get(userTuple,:node_client)})
        end)
       else
        tweets_based_has_subscribed_to_for_given_user=[]
       end


     #IO.inspect nodes_id_for_tweets

end 

 def start_boss(server_tuple) do
        serverName=String.to_atom(to_string("server@")<>elem(server_tuple,0))
        {:ok,_}=Node.start(serverName)
        cookie=Application.get_env(:project3, :cookie)
        {:ok,_} = GenServer.start_link(__MODULE__, :ok, name: Boss_Server)  # -> Created the boss process
        Node.set_cookie(cookie)
        :global.register_name(:boss_server,self())
        IO.inspect Node.self()
 end

end