defmodule Project4Part1.Node do
use GenServer

@numTweets 2

#Server Side Implementation
    def init(_) do  
        {:ok,%{:is_logged_in=>true,:is_fresh_user=>true}}
    end

    def handle_cast({:tweet,name_of_user,client_node_name,server_node_name,id_tweeter,reference},state)do
        if(state[:is_logged_in]==true and state[:is_fresh_user]==true) do
            
            random_tweet_text=Project4Part1.LibFunctions.randomizer(32,:downcase)
            random_hashTag="#"<>Project4Part1.LibFunctions.randomizer(8,true)
            random_tweet=random_tweet_text<>random_hashTag
            GenServer.cast({Boss_Server,server_node_name},{:got_tweet,random_tweet,random_hashTag,name_of_user,client_node_name,id_tweeter,reference})

            # Update the is_fresh_user status to false
            {_,state_random_is_fresh_user}=Map.get_and_update(state,:is_fresh_user, fn current_value -> {current_value,false} end)
            state=Map.merge(state,state_random_is_fresh_user)

        else if(state[:is_logged_in]==true and state[:is_fresh_user]==false) do
            
            random_tweet_text=Project4Part1.LibFunctions.randomizer(32,:downcase)
            random_hashTag="#"<>Project4Part1.LibFunctions.randomizer(8,true)
            random_tweet=random_tweet_text<>random_hashTag
            GenServer.cast({Boss_Server,server_node_name},{:got_tweet,random_tweet,random_hashTag,name_of_user,client_node_name,id_tweeter,reference})

        else
            #Do Nothing
             end
        end
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

    #Client Side Implementation

    #start process on the given node for a given client node
    def start(id_tweeter,server_node_name,client_node_name) do
        name_of_node=String.to_atom("tweeter@user"<>to_string(id_tweeter))
        password=Project4Part1.LibFunctions.randomizer(8,true)
        {:ok,_} = GenServer.start_link(__MODULE__,password,name: name_of_node)
        GenServer.cast({Boss_Server,server_node_name},{:created_user,client_node_name,password,name_of_node,id_tweeter})
        {name_of_node,client_node_name}
    end

    def generate_name(args) do
        machine = to_string("localhost")
        IO.inspect args
        ipaddress=to_string(Enum.at(args,1))
        hex = :erlang.monotonic_time() |>
          :erlang.phash2(256) |>
          Integer.to_string(16)
        String.to_atom("#{machine}-#{hex}@#{ipaddress}")
    end
    
    def start_client(args)do
        clientName=generate_name(args)
        {:ok,_}= Node.start(clientName)
        cookie=Application.get_env(:project1, :cookie)
        Node.set_cookie(cookie)
        {Node.self,args}
    end

    def connect_to_server(tuple)do
        server_name=String.to_atom(to_string("server@"<> Enum.at(elem(tuple,1),1)))
        Node.connect(server_name)
        {numNode,_}=Integer.parse(Enum.at(elem(tuple,1),2))
        l= spawn_nodes(numNode,1,[],server_name,elem(tuple,0))
        #IO.inspect l
        random_subscriptions(l,1,server_name)
        GenServer.cast({Boss_Server,server_name},{:here})

    end

      def spawn_nodes(numNodes,start_value,l,server_node_name,client_node_name) do

             if(start_value<=numNodes) do
                name_of_node=Project4Part1.Node.start(start_value,server_node_name,client_node_name)
                l=l++[name_of_node]
                create_tweet_for_user(@numTweets,elem(name_of_node,0),1,server_node_name,client_node_name,start_value,nil)
                start_value=start_value+1
                l=spawn_nodes(numNodes,start_value,l,server_node_name,client_node_name)
             end
             l  
      end
    
      def create_tweet_for_user(numtweets,name_of_user,start_value,server_node_name,client_node_name,id_tweeter,reference)do
            if(start_value<=numtweets)do
                GenServer.cast({name_of_user,client_node_name},{:tweet,name_of_user,client_node_name,server_node_name,id_tweeter,reference})
                start_value=start_value+1
                create_tweet_for_user(numtweets,name_of_user,start_value,server_node_name,client_node_name,id_tweeter,reference)
            end
      end

    def random_subscriptions(list, start,server_name) do

        if(start<=length(list)) do
            listLength=length(list)
            numberList=1..listLength
            random_number_subscriptions=Enum.random(numberList)-1
            element=Enum.at(list,start-1);
            newList=list--[element]
            generate_subscriptions(newList,1,random_number_subscriptions,server_name,element)
            start=start+1
            random_subscriptions(list, start,server_name) 
        end
        
    end

    def generate_subscriptions(list,startValue,random_number_subscriptions,server_name,node)do
       if(startValue<=random_number_subscriptions) do
           random_node_choose=Enum.random(list);
           list=list--[random_node_choose]
           GenServer.cast({Boss_Server,server_name},{:add_subscription_for_given_client_user,random_node_choose,node})
           startValue=startValue+1;
           generate_subscriptions(list,startValue,random_number_subscriptions,server_name,node)
       end 
    end

    

end
