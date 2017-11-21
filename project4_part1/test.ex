defmodule Project4Part1.Node do
    
    use GenServer
    
        
    
        #Generate Node process
    
        def start(id_tweeter) do
    
            name_of_node=String.to_atom("tweeter@user"<>to_string(id_tweeter))
    
            password=Project4Part1.LibFunctions.randomizer(8,true)
    
            {:ok,_} = GenServer.start_link(__MODULE__,password,name: name_of_node)
    
            name_of_node
    
        end
    
    
    
        #Server Side Implementation
    
        def init(args) do   
    
            {:ok,%{:password => args, :users_subscribers => []}}
    
        end
    
    
    
        def handle_cast({:check},state)do
    
            #IO.puts "I am here in #{inspect self()} #{inspect state[:password]}"
    
            {:noreply,state}
    
        end
    
    
    
        #This is the list of random subscriptions that a user has
    
        def handle_cast({:receive_list,list, name_of_node}, state) do
    
            random_list=[]
    
            subscribed_list=random_subscriptions(list, 0, name_of_node,random_list)
    
            IO.puts "Subscribed list #{inspect name_of_node} #{inspect subscribed_list}"
    
            GenServer.cast(name_of_node,{:print_subscribers, name_of_node})
    
            {:noreply, state}
    
        end
    
    
    
       # This is the random subscription initially 
    
        def random_subscriptions(list, start, name_of_node, random_list) do
    
            if(start < 3) do
    
                subs = Enum.random(list)
    
                list = list -- [subs]
    
                if(!Enum.member?(random_list, subs)) do
    
                    random_list = random_list ++ [subs]
    
                    GenServer.cast(subs, {:add_subscriber,name_of_node}) # When you add a random subscriptio also update the subscriber 
    
                    start=start+1
    
                end
    
                random_list = random_subscriptions(list, start, name_of_node, random_list)
    
            end
    
            random_list
    
        end
    
    
    
        def handle_cast({:add_subscriber, name_of_node}, state) do
    
            {_,state_users_subscribers}=Map.get_and_update(state,:users_subscribers, fn current_value -> {current_value,current_value++[name_of_node]} end)
    
            state=Map.merge(state,state_users_subscribers)
    
            {:noreply,state}   
    
        end
    
    
    
        def handle_cast({:print_subscribers, name_of_node}, state) do
    
            IO.puts "#{inspect name_of_node} ===== #{inspect state[:users_subscribers]}"
    
            {:noreply, state}
    
        end
    
    end
    
    