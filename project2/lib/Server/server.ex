defmodule Project2.Server do
use GenServer
@gossip 10

    def start_server_node(server_tuple) do
        serverName=String.to_atom(to_string("server@")<>elem(server_tuple,0))
        {:ok,_}=Node.start(serverName)
        cookie=Application.get_env(:project1, :cookie)
        Node.set_cookie(cookie)
        numNodes=String.to_integer(to_string(Enum.at(elem(server_tuple,1),0)));
        topology=to_string(Enum.at(elem(server_tuple,1),1));

        if(topology=="2D") do
            numNodes=round(:math.pow(round(:math.sqrt(numNodes)),2))
        end
        #IO.inspect numNodes
        list=spawn_processes(numNodes,1,[])
        IO.inspect list
        creating_topology_for_each_actor(0,topology,list)
        #GenServer.cast(Enum.random(list),{:startGossip})
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
                      l = get_neighbours(start_value,topology,list,0,[])
                      l

            "2D" -> l = get_neighbours(start_value,topology,list,0,[])
                    l

            "line" -> l = get_neighbours(start_value,topology,list,0,[])
                      l

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

            "2D" -> 
                    n=round(:math.sqrt(Enum.count(list))) #Value of grid n*n grid
                    
                    # Forward nth Neighbour
                    if((position+n)>Enum.count(list)) do
                        #Do nothing
                    else
                        l=l++[Enum.at(list,position+n)]
                    end

                    # Backward nth Neighbour
                    if((position-n)<0) do
                        #Do nothing
                    else
                        l=l++[Enum.at(list,position-n)]
                    end

                    # Forward one Neighbour
                    if( rem((position+1),n)==0) do
                        #Do nothing
                    else
                        l=l++[Enum.at(list,position+1)]
                    end

                    # Backward one Neighbour
                    if(
                     ((position-1)<0) or 
                     ((rem((position-1),n))!=0 and (rem(position,n)==0))
                     ) do
                    #Do nothing
                    else
                        l=l++[Enum.at(list,position-1)]
                    end
                    l=List.delete(l,nil)
                    IO.puts "#{n}    #{inspect l}"

            "line" -> 
                   # IO.puts position
                   # IO.puts Enum.count(list)-1
                    if((position==0)==true) do
                        #IO.puts "Entered 0"
                        l=l++[Enum.at(list,position+1)]
                        #IO.inspect l
                    else if((position==Enum.count(list)-1)==true)do
                         #IO.puts "Entered last"
                         l=l++[Enum.at(list,position-1)]
                         #IO.inspect l
                    else 
                        #IO.puts "Entered mid"
                        l=l++[Enum.at(list,position-1)]
                        l=l++[Enum.at(list,position+1)] 
                        #IO.inspect l
                        end
                      end

                    l
            "imp2D" -> IO.puts "Still to do"
         end

        l
    end


   # Genserver processes start
   def start(start_value) do
        {:ok,pid} = GenServer.start_link(__MODULE__,:ok,name: String.to_atom(to_string(start_value)))
        pid
        #String.to_atom(to_string(start_value))
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
        IO.puts "#{inspect self()} #{inspect state}"
        {:noreply,state}
    end

    def handle_cast({:startGossip},state) do
        IO.puts "#{inspect self()} #{state[:count]}"

        if(state[:count]>=@gossip) do
            kill_actor(self())
        else
            {_,state_list_count}=Map.get_and_update(state,:count, fn current_value -> {current_value,current_value+1} end)
            state=Map.merge(state,state_list_count)
            neighbour=Enum.random(state[:list_of_neighbours])
            IO.puts "neighbour #{inspect neighbour}"
            if neighbour_is_alive(neighbour) do
                GenServer.cast(neighbour,{:startGossip})
                 Process.sleep(1_00)
                if(state[:count]<@gossip) do
                     GenServer.cast(self(),{:startGossip})
                end
            else
                Process.sleep(1_00)
                if(state[:count]<@gossip) do
                     GenServer.cast(self(),{:startGossip})
                end
            end
             {:noreply,state}
        end

        {:noreply,state}
    end
 
    def neighbour_is_alive(process_id) do
        if(Process.alive?(process_id)) do
            true
        else 
            false
        end
    end

    def kill_actor(process_id) do
        IO.puts "Killing #{inspect process_id}"
        Process.exit(process_id,:normal)
        #IO.puts "Killed"
    end

end