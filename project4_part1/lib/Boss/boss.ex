defmodule Project4Part1.Boss do
use GenServer


def init(:ok) do
        {:ok,%{:nodes => [],:hashTag => [],:tweets=>[],:reference=>[],:tweet_by_user => [],:users=>[]}}
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

def handle_cast({:got_tweet,random_tweet,random_hashTag,name_of_user,client_node_name,tweeter_id,reference},state)do

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

        #IO.inspect state
        {:noreply,state}
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

def handle_cast({:got_retweet,client_node_name,hashTag,tweets,reference,name_of_user},state) do

        # {:ok,%{:nodes => [],:hashTag => [],:tweets=>[],:reference=>[],:tweet_by_user => [],:users=>[]}}

        {_,state_random_node}=Map.get_and_update(state,:nodes, fn current_value -> {current_value,current_value++[client_node_name]} end)
        state=Map.merge(state,state_random_node)

        {_,state_random_hashTag}=Map.get_and_update(state,:hashTag, fn current_value -> {current_value,current_value++[hashTag]} end)
        state=Map.merge(state,state_random_hashTag)
        
        {_,state_random_tweet}=Map.get_and_update(state,:tweets, fn current_value -> {current_value,current_value++[tweets]} end)
        state=Map.merge(state,state_random_tweet)

        {_,state_random_tweet_user}=Map.get_and_update(state,:tweet_by_user, fn current_value -> {current_value,current_value++[name_of_user]} end)
        state=Map.merge(state,state_random_tweet_user)

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

def handle_cast({:here},state) do
    IO.inspect Enum.count(state[:hashTag])
    
    #Login a random user as of now
    login_query_for_client(state)
    {:noreply,state}
end

def login_query_for_client(state)do
     userTuple=Enum.at(state[:users],0)
    
     tweets=state[:tweets]
     hashTag=state[:hashTag]
     reference=state[:reference]
     tweet_by_user=state[:tweet_by_user]
     user_preferred_hashtags=userTuple[:hashTags]
     user_has_subscibed_to_list=userTuple[:has_subscribed_to]
     nodes_tweeting=state[:nodes]

     IO.inspect state
     IO.inspect user_has_subscibed_to_list

     # User Preferred Tag Tweets
     hashTags_indices_for_user_preferred_tags=Enum.filter(Enum.map(user_preferred_hashtags,fn(x)-> Enum.find_index(hashTag,fn(y) -> x==y  end)  end), & !is_nil(&1))
     if(length(hashTags_indices_for_user_preferred_tags)>0) do
        tweets_based_user_preferred_hashTags=Enum.map(hashTags_indices_for_user_preferred_tags,fn(x)-> to_string(Enum.at(tweets,x))<>" By user "<>to_string(Enum.at(tweet_by_user,x)) end) 
        GenServer.cast({Map.get(userTuple,:name_node),Map.get(userTuple,:node_client)},{:here,tweets_based_user_preferred_hashTags})
     else
        tweets_based_user_preferred_hashTags=[]
     end 

     # User Referred in Tweets
     references_indices_where_user_is_mentioned=Enum.filter(Enum.map(Enum.with_index(reference),fn({x,i})-> 
                if(x==Map.get(userTuple,:name_node)) do i end end),& !is_nil(&1))

      if(length(references_indices_where_user_is_mentioned)>0) do
        tweets_based_references_for_given_user=Enum.map(references_indices_where_user_is_mentioned,fn(x)-> to_string(Enum.at(tweets,x))<>" By user "<>to_string(Enum.at(tweet_by_user,x)) end) 
        GenServer.cast({Map.get(userTuple,:name_node),Map.get(userTuple,:node_client)},{:here,tweets_based_references_for_given_user})
      else
        tweets_based_references_for_given_user=[]
      end

     # User has Subscribed to Tweets
       nodes_id_for_tweets=Enum.map(Enum.filter(Enum.with_index(Enum.map(Enum.with_index(tweet_by_user),fn({x,i})-> Enum.find_index(user_has_subscibed_to_list,fn(y)-> x==elem(y,0) end) end)),fn({x,i})-> x end),fn({x,i})-> i end)
       
       if(length(nodes_id_for_tweets)>0) do
        tweets_based_has_subscribed_to_for_given_user=Enum.map(nodes_id_for_tweets,fn(x)-> to_string(Enum.at(tweets,x))<>" By user "<>to_string(Enum.at(tweet_by_user,x)) end) 
        GenServer.cast({Map.get(userTuple,:name_node),Map.get(userTuple,:node_client)},{:here,tweets_based_has_subscribed_to_for_given_user})
       else
        tweets_based_has_subscribed_to_for_given_user=[]
       end


     IO.inspect nodes_id_for_tweets

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