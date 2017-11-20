defmodule Project4Part1.Boss do
use GenServer

def init(:ok) do
        {:ok,%{:tweet => [], :tweet_text=> [] ,:name_node => [],:hashTag => [] }}
end

def handle_cast({:got_tweet,random_tweet,random_tweet_text,random_hashTag,name_node},state)do


        {_,state_random_tweet}=Map.get_and_update(state,:tweet, fn current_value -> {current_value,current_value++[random_tweet]} end)
        state=Map.merge(state,state_random_tweet)

        {_,state_random_tweet_text}=Map.get_and_update(state,:tweet_text, fn current_value -> {current_value,current_value++[random_tweet_text]} end)
        state=Map.merge(state,state_random_tweet_text)

        {_,state_random_tweet_tweeter}=Map.get_and_update(state,:name_node, fn current_value -> {current_value,current_value++[name_node]} end)
        state=Map.merge(state,state_random_tweet_tweeter)

        {_,state_random_tweet_hashTag}=Map.get_and_update(state,:hashTag, fn current_value -> {current_value,current_value++[random_hashTag]} end)
        state=Map.merge(state,state_random_tweet_hashTag)
        
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
        spawn_nodes(numNodes,1,[])
 end

 def spawn_nodes(numNodes,start_value,l) do
             if(start_value<=numNodes) do
                l=l++[Project4Part1.Node.start(start_value)]
                #name_of_node=String.to_atom("tweeter@user"<>to_string(start_value))
                #GenServer.cast(name_of_node,{:check})
                start_value=start_value+1
                l=spawn_nodes(numNodes,start_value,l)
             end
             l
 end
end