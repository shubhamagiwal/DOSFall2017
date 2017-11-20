defmodule Project4Part1.Node do
use GenServer
    
    #Generate Node process
    def start(id_tweeter) do
        name_of_node=String.to_atom("tweeter@user"<>to_string(id_tweeter))
        password=Project4Part1.LibFunctions.randomizer(8,true)
        {:ok,_} = GenServer.start_link(__MODULE__,password,name: name_of_node)
        GenServer.cast(Boss_Server,{:created_user,name_of_node})
        name_of_node
    end

    #Server Side Implementation
    def init(args) do  
        #IO.puts "#{inspect self} #{inspect args}" 
        {:ok,%{:password => args, :isFreshUser => true}}
    end

    def handle_cast({:update_user_status,status},state)do
          {_,state_isFreshUser}=Map.get_and_update(state,:isFreshUser, fn current_value -> {current_value,true} end)
          state=Map.merge(state,state_isFreshUser)
          {:noreply,state}
    end

    def handle_cast({:tweet,name_node},state)do
        random_tweet_text=Project4Part1.LibFunctions.randomizer(32,:downcase)
        random_hashTag=" #"<>Project4Part1.LibFunctions.randomizer(8,true)
        random_tweet=random_tweet_text<>random_hashTag
        IO.puts "#{inspect name_node} tweet: #{inspect random_tweet}"
        GenServer.cast(Boss_Server,{:got_tweet,random_tweet,random_tweet_text,random_hashTag,name_node})
        {:noreply,state}
    end

    def handle_cast({:check},state)do
        IO.puts "I am here in #{inspect self()} #{inspect state[:password]}"
        {:noreply,state}
    end

end
