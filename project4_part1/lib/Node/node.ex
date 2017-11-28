defmodule Project4Part1.Node do
use GenServer

@numTweets 1
@numHashTags 1
@numberOfSubscriptions 1
#Server Side Implementation
    def init(args) do  
        schedule_periodic_login_and_logout()
        {:ok,%{:is_logged_in=>true,:is_fresh_user=>true,:boss_node=>args, :clientName => nil, :clientNode => nil }}
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
            GenServer.cast(state[:clientName],{:login})

        end

        schedule_periodic_login_and_logout() 
        {:noreply, state}
    end


    def handle_cast({:tweet,name_of_user,client_node_name,reference},state)do
        server_node_name=state[:boss_node]

        if(state[:is_logged_in]==true and state[:is_fresh_user]==true) do
            
            random_tweet_text=Project4Part1.LibFunctions.randomizer(32,:downcase)
            random_hashTag="#"<>Project4Part1.LibFunctions.randomizer(8,true)
            random_tweet=random_tweet_text<>random_hashTag

            GenServer.cast({Boss_Server,server_node_name},{:got_tweet,random_tweet,random_hashTag,name_of_user,client_node_name,reference,state[:is_fresh_user]})

            # Update the is_fresh_user status to false
            {_,state_random_is_fresh_user}=Map.get_and_update(state,:is_fresh_user, fn current_value -> {current_value,false} end)
            state=Map.merge(state,state_random_is_fresh_user)

        else if(state[:is_logged_in]==true and state[:is_fresh_user]==false) do
            
            random_tweet_text=Project4Part1.LibFunctions.randomizer(32,:downcase)
            random_hashTag="#"<>Project4Part1.LibFunctions.randomizer(8,true)
            random_tweet=random_tweet_text<>random_hashTag
            GenServer.cast({Boss_Server,server_node_name},{:got_tweet,random_tweet,random_hashTag,name_of_user,client_node_name,reference,state[:is_fresh_user]})

        else
            #Do Nothing
             end
        end

        {:noreply,state}
    end

    def handle_cast({:mention_tweet,client_node_name,name_of_user},state)do
        server_node_name=state[:boss_node]
        {_,hashTag,tweet,_,reference,reference_node}=GenServer.call({Boss_Server,server_node_name},{:get_random_tweet_for_mention,name_of_user,client_node_name},:infinity)
        tweet=tweet<>" @"<>to_string(reference)
        GenServer.cast({Boss_Server,server_node_name},{:got_mention_tweet,client_node_name,name_of_user,tweet,hashTag,reference,reference_node})
        #GenServer.cast({Boss_Server,server_node_name},{:get_random_tweet_for_mention,name_of_user,client_node_name})
        {:noreply,state}
     end

    def handle_cast({:retweet,random_tweet,random_hashtag,name_of_user,client_node_name,reference,reference_node,original_tweet_node,original_tweet_user},state)do
          if(state[:is_logged_in]==true) do
                IO.puts "#{inspect name_of_user} of #{inspect client_node_name}:Got a retweet #{inspect random_tweet} from  #{inspect original_tweet_user} of  #{inspect original_tweet_node} "
          end
        {:noreply,state}
    end

    def handle_cast({:got_a_tweet,random_tweet,random_hashtag,name_of_user,client_node_name,_,client_name_x,client_node_name_x},state) do
        server_node_name=state[:boss_node]

        if(state[:is_logged_in]==true) do
            IO.puts "#{inspect client_name_x} of #{inspect client_node_name_x}:Got a tweet #{inspect random_tweet} from  #{inspect name_of_user} of  #{inspect client_node_name} "
            retweet_status=check_for_probability_for_retweet()

            if(retweet_status)do
                GenServer.cast({Boss_Server,server_node_name},{:got_retweet,client_node_name_x,client_name_x,random_tweet,random_hashtag,nil,nil})
            end

        end
        {:noreply,state}
    end

    def handle_cast({:got_a_tweet_with_mention,reference,reference_node,name_of_user,client_node_name,tweet,random_hashtag},state) do
        
        server_node_name=state[:boss_node]

        if(state[:is_logged_in]==true) do
           IO.puts "#{inspect reference} of #{inspect reference_node}:Got a tweet #{inspect tweet} from  #{inspect name_of_user} of  #{inspect client_node_name} " 

           retweet_status=check_for_probability_for_retweet()
            
           if(retweet_status)do
                GenServer.cast({Boss_Server,server_node_name},{:got_retweet,reference_node,reference,tweet,random_hashtag,nil,nil})
           end
        
        end

         {:noreply,state}
    end

    def check_for_probability_for_retweet() do
        list=Enum.to_list(1..5)
        value=false
        if(Enum.random(list)==4) do
            value=true
        end
        value
    end
 
    def handle_cast({:login},state)do
          # {:ok,%{:is_logged_in=>true,:is_fresh_user=>true,:boss_node=>args, :clientName => nil, :clientNode => nil }}
          GenServer.cast({Boss_Server,state[:boss_node]},{:query,state[:clientNode],state[:clientName]})
          {:noreply,state}
     end

    def handle_cast({:update_client_state,clientName,clientNode},state)do

        {_,state_isLoggedIn}=Map.get_and_update(state,:clientName, fn current_value -> {current_value,clientName} end)
        state=Map.merge(state,state_isLoggedIn)

        {_,state_isLoggedIn}=Map.get_and_update(state,:clientNode, fn current_value -> {current_value,clientNode} end)
        state=Map.merge(state,state_isLoggedIn)
        
        {:noreply,state}
    end

    #Client Side Implementation

    #start process on the given node for a given client node
    def start(id_tweeter,server_node_name,client_node_name) do
        name_of_node=String.to_atom("tweeter@user"<>to_string(id_tweeter))
        password=Project4Part1.LibFunctions.randomizer(8,true)
        {:ok,_} = GenServer.start_link(__MODULE__,server_node_name,name: name_of_node)
        GenServer.cast({name_of_node,Node.self()}, {:update_client_state,name_of_node,Node.self()})
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
        startValue=GenServer.call({Boss_Server,server_name},{:get_start_value},:infinity)
        GenServer.cast({Boss_Server,server_name},{:update_start_value,startValue+numNode})
        l= spawn_nodes(numNode+startValue,startValue,[],server_name,elem(tuple,0))
        IO.inspect l

        list=GenServer.call({Boss_Server,server_name},{:get_list_users},:infinity)
        
        if(length(list)>0)do
            l=list
        end

        random_subscriptions(l,1,server_name)
        random_hashTags_for_a_given_user(server_name,@numHashTags,l,0)
        IO.puts "Done"
        #Process.sleep(1_000)
        #GenServer.cast({Boss_Server,server_name},{:here})
        #:retweet,client_node_name,name_of_user
        #{name_of_node,client_node_name}=Enum.random(l)
        #GenServer.cast({name_of_node,client_node_name},{:mention_tweet,client_node_name,name_of_node})
        #{:zipf_distribution,client_name,client_node_name,numNodes}
        #IO.puts "I am here"
        Enum.each(l,fn({name_node_x,client_node_x})-> GenServer.cast({Boss_Server,server_name},{:zipf_distribution,name_node_x,client_node_x,numNode})  end)


    end

      def spawn_nodes(numNodes,start_value,l,server_node_name,client_node_name) do

             if(start_value<=numNodes) do
                name_of_node=Project4Part1.Node.start(start_value,server_node_name,client_node_name)
                l=l++[name_of_node]
                create_tweet_for_user(@numTweets,elem(name_of_node,0),1,server_node_name,client_node_name,start_value,nil)
                {name_of_node_node,client_node_name}=name_of_node
                GenServer.cast({name_of_node_node,client_node_name},{:mention_tweet,client_node_name,name_of_node_node})
                start_value=start_value+1
                l=spawn_nodes(numNodes,start_value,l,server_node_name,client_node_name)
             end
             l  
      end
    
      def create_tweet_for_user(numtweets,name_of_user,start_value,server_node_name,client_node_name,id_tweeter,reference)do
            if(start_value<=numtweets)do
                GenServer.cast({name_of_user,client_node_name},{:tweet,name_of_user,client_node_name,reference})
                start_value=start_value+1
                create_tweet_for_user(numtweets,name_of_user,start_value,server_node_name,client_node_name,id_tweeter,reference)
            end
      end

    def random_subscriptions(list, start,server_name) do

        if(start<=length(list)) do
            listLength=length(list)
            numberList=1..listLength
            #random_number_subscriptions=Enum.random(numberList)-1
            random_number_subscriptions=@numberOfSubscriptions
            element=Enum.at(list,start-1);
            newList=list--[element]
            #IO.inspect newList
            generate_subscriptions(newList,1,random_number_subscriptions,server_name,element)
            start=start+1
            random_subscriptions(list, start,server_name) 
        end
        
    end

    def generate_subscriptions(list,startValue,random_number_subscriptions,server_name,node)do
       if(startValue<=random_number_subscriptions) do
           random_node_choose=Enum.random(list);
           #IO.inspect random_node_choose
           list=list--[random_node_choose]
           IO.puts "I am here"
           GenServer.cast({Boss_Server,server_name},{:add_subscription_for_given_client_user,random_node_choose,node})
           GenServer.cast({Boss_Server,server_name},{:add_is_subscribed_for_given_client,random_node_choose,node})
           startValue=startValue+1;
           generate_subscriptions(list,startValue,random_number_subscriptions,server_name,node)
       end 
    end

    def random_hashTags_for_a_given_user(servername,numHashTags,list,start) do
        
        if(start<=length(list)) do
            element=Enum.at(list,start-1);
            GenServer.cast({Boss_Server,servername},{:assign_hashTags_to_user,numHashTags,element})
            start=start+1
            random_hashTags_for_a_given_user(servername, numHashTags,list,start) 
        end
    end

    

end
