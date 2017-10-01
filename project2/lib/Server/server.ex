defmodule Project2.Server do
use GenServer

    def start_server_node(server_tuple) do
        serverName=String.to_atom(to_string("server@")<>elem(server_tuple,0))
        {:ok,_}=Node.start(serverName)
        cookie=Application.get_env(:project1, :cookie)
        Node.set_cookie(cookie)
        list=spawn_processes(String.to_integer(to_string(Enum.at(elem(server_tuple,1),0))),1,[])
        IO.inspect list
        #GenServer.cast(Enum.at(list,0),{:got,"Awesome"})
        #GenServer.cast(Enum.at(list,1),{:got,"Awesome2"})
        creating_topology_for_each_actor(0,Enum.at(elem(server_tuple,1),1),list)
        #creating_topology(to_string(Enum.at(elem(server_tuple,1),1)),list)
    end

    def spawn_processes(numNodes,start_value,l) do
             if(start_value<=numNodes) do
                l=l++[start(start_value)]
                start_value=start_value+1
                l=spawn_processes(numNodes,start_value,l)
             end
             l
    end

    def creating_topology_for_each_actor(start_value,topology,list) do
            if(start_value<Enum.count(list)) do
                list_of_neighbours=creating_topology(start_value,topology,list)
                GenServer.cast(Enum.at(list,start_value),{:update,topology,list_of_neighbours})
                start_value=start_value+1
                creating_topology_for_each_actor(start_value,topology,list)
            end


    end

   

    def creating_topology(start_value,topology,list) do

         case topology do

            "full" -> 
                      l = get_neighbours(start_value,"full",list,0,[])
                      l

            "2D" -> IO.puts "Still to do"

            "line" -> IO.puts "Still to do"

            "imp2D" -> IO.puts "Still to do"
         end

    end

    def get_neighbours(position,topology,list,start_value,l) do

        case topology do

            "full" -> 
                #IO.inspect l
            if(start_value<Enum.count(list)) do
                #IO.puts "#{start_value}   #{position}"
                #IO.inspect ((start_value==position)==false)
                 if(((start_value==position)==false)) do
                    l=l++[Enum.at(list,start_value)]
                    #IO.puts "Entered equal #{start_value}"
                end
                start_value=start_value+1
                l=get_neighbours(position,topology,list,start_value,l)
             end

            "2D" -> IO.puts "Still to do"

            "line" -> IO.puts "Still to do"

            "imp2D" -> IO.puts "Still to do"
         end

        l
    end


   # Genserver processes start
   def start(start_value) do
        {:ok,pid} = GenServer.start_link(__MODULE__,:ok,name: String.to_atom(to_string(start_value)))
        #pid
        String.to_atom(to_string(start_value))
    end

    #Server Side Implementation
    def init(:ok) do
        # First is Rumor
        {:ok,%{}}
    end

    def handle_cast({:update,topology,list_of_neighbours},state) do
        #state[:topology]=topology
        #%{state | :list_of_neighbours => list_of_neighbours}
        #IO.inspect state
        #IO.inspect list_of_neighbours
        {_,state_list_neighbours}=Map.get_and_update(state,:list_of_neighbours, fn current_value -> {current_value,list_of_neighbours} end)
        {_,state_list_count}=Map.get_and_update(state,:count, fn current_value -> {current_value,0} end)
        {_,state_list_topology}=Map.get_and_update(state,:topology, fn current_value -> {current_value,topology} end)
        state=Map.merge(state,state_list_neighbours)
        state=Map.merge(state,state_list_count)
        state=Map.merge(state,state_list_topology)
        IO.inspect state
        {:noreply,state}
    end



end