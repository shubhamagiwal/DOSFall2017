defmodule Project4Part1.Node do
use GenServer
    
    #Generate Node process
    def start(id_tweeter) do
        name_of_node=String.to_atom("tweeter@user"<>to_string(id_tweeter))
        password=Project4Part1.LibFunctions.randomizer(8,true)
        {:ok,_} = GenServer.start_link(__MODULE__,password,name: name_of_node)
        isFreshUser=true
        isLoggedIn=true
        GenServer.cast(Boss_Server,{:created_user,name_of_node,password,isFreshUser,isLoggedIn})
        name_of_node
    end

    #Server Side Implementation
    def init(args) do  
        {:ok,%{:is_logged_in=>true,:is_fresh_user=>true, :users_subscribers=>[]}}
    end

    def handle_cast({:tweet,name_node,tweeter_id},state)do
        if(state[:is_logged_in]==true) do
            random_tweet_text=Project4Part1.LibFunctions.randomizer(32,:downcase)
            random_hashTag="#"<>Project4Part1.LibFunctions.randomizer(8,true)
            random_tweet=random_tweet_text<>random_hashTag
            #IO.puts "#{inspect name_node} tweet: #{inspect random_tweet}"
            GenServer.cast(Boss_Server,{:got_tweet,random_tweet,random_hashTag,name_node,tweeter_id})
        else
            #Do Nothing
        end
        {:noreply,state}
    end

    def handle_cast({:users_subscribers, user},state) do
        {_,state_users_subscribers}=Map.get_and_update(state,:users_subscribers, fn current_value -> {current_value, current_value ++ [user]} end)
        state=Map.merge(state,state_users_subscribers)
        #IO.puts "User #{inspect user} ====state==== #{inspect state[:users_subscribers]}"
        {:noreply,state}
    end

     def handle_cast({:login},state)do
          {_,state_isLoggedIn}=Map.get_and_update(state,:is_logged_in, fn current_value -> {current_value,true} end)
          state=Map.merge(state,state_isLoggedIn)
          {:noreply,state}
    end

    def handle_cast({:logout},state)do
          {_,state_isLoggedIn}=Map.get_and_update(state,:is_logged_in, fn current_value -> {current_value,false} end)
          state=Map.merge(state,state_isLoggedIn)
          {:noreply,state}
    end

end
