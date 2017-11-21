defmodule Project4Part1.Boss do
use GenServer
@numTweets 2

def init(:ok) do
        {:ok,%{:name_node => [],:hashTag => [],:tweet_user=>[],:tweet=>[]}}
end

def handle_cast({:created_user,name_node,password,isFreshUser,isLoggedIn},state)do

      process_map=%{:name_node => nil, :password => nil, :is_fresh_user=>nil,:is_logged_in => nil, :tweets =>[] , :subscribers => [], :subscribees => [], :hashTags => []  }

      {_,state_name_node}=Map.get_and_update(process_map,:name_node, fn current_value -> {current_value,name_node} end)
      process_map=Map.merge(process_map,state_name_node)

      {_,state_password}=Map.get_and_update(process_map,:password, fn current_value -> {current_value,password} end)
      process_map=Map.merge(process_map,state_password)

      {_,state_tweets}=Map.get_and_update(process_map,:tweets, fn current_value -> {current_value,[]} end)
      process_map=Map.merge(process_map,state_tweets)

       {_,state_subscribers}=Map.get_and_update(process_map,:subscribers, fn current_value -> {current_value,[]} end)
      process_map=Map.merge(process_map,state_subscribers)

      {_,state_subscribees}=Map.get_and_update(process_map,:subscribees, fn current_value -> {current_value,[]} end)
      process_map=Map.merge(process_map,state_subscribees)

      {_,state_hashtags}=Map.get_and_update(process_map,:hashTags, fn current_value -> {current_value,[]} end)
      process_map=Map.merge(process_map,state_hashtags)
      
      {_,state_random_tweet}=Map.get_and_update(state,:tweet_user, fn current_value -> {current_value,current_value++[process_map]} end)
      state=Map.merge(state,state_random_tweet)

      {_,state_random_name_node}=Map.get_and_update(state,:name_node, fn current_value -> {current_value,current_value++[name_node]} end)
      state=Map.merge(state,state_random_name_node)
      
      #IO.inspect state
      {:noreply,state}
end

def handle_cast({:got_tweet,random_tweet,random_hashTag,name_node,tweeter_id},state)do

        tweeter_user_state=Enum.at(state[:tweet_user],tweeter_id-1)

        {_,state_random_tweet}=Map.get_and_update(tweeter_user_state,:tweets, fn current_value -> {current_value,current_value++[random_tweet]} end)
        tweeter_user_state=Map.merge(tweeter_user_state,state_random_tweet)

        modified_tweet_user_list= List.replace_at(state[:tweet_user],tweeter_id-1,tweeter_user_state)

        {_,state_updated_tweet_user_list}=Map.get_and_update(state,:tweet_user, fn current_value -> {current_value,modified_tweet_user_list} end)
        state=Map.merge(state,state_updated_tweet_user_list)

        {_,state_updated_tweet_hashTag}=Map.get_and_update(state,:hashTag, fn current_value -> {current_value,current_value++[random_hashTag]} end)
        state=Map.merge(state,state_updated_tweet_hashTag)

        {_,state_updated_tweet_tweet}=Map.get_and_update(state,:tweet, fn current_value -> {current_value,current_value++[random_tweet]} end)
        state=Map.merge(state,state_updated_tweet_tweet)

        #IO.inspect state
        {:noreply,state}
end

def handle_cast({:update_user_status},state)do

         IO.inspect state
         {:noreply,state}
    end

 def start_boss(server_tuple) do
        serverName=String.to_atom(to_string("server@")<>elem(server_tuple,0))
        {:ok,_}=Node.start(serverName)
        cookie=Application.get_env(:project3, :cookie)
        {:ok,_} = GenServer.start_link(__MODULE__, :ok, name: Boss_Server)  # -> Created the boss process
        Node.set_cookie(cookie)

        numNodes=String.to_integer(to_string(Enum.at(elem(server_tuple,1),0)))

        # Spawn the given numNodes which is registering an account with a password
        spawn_nodes(numNodes,1)

        Process.sleep(1_00)

         GenServer.cast(Boss_Server,{:update_user_status})
 end

 def spawn_nodes(numNodes,start_value) do

             if(start_value<=numNodes) do
                name_of_node=Project4Part1.Node.start(start_value)
                create_tweet_for_user(@numTweets,name_of_node,1,start_value)
                start_value=start_value+1
                l=spawn_nodes(numNodes,start_value)
             end
           
  end

    def create_tweet_for_user(numtweets,name_of_user,start_value,id_tweeter)do

        if(start_value<=numtweets)do
            GenServer.cast(name_of_user,{:tweet,name_of_user,id_tweeter})
            start_value=start_value+1
            create_tweet_for_user(numtweets,name_of_user,start_value,id_tweeter)
        end
    end

end