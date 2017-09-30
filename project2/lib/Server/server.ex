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
        creating_topology(to_string(Enum.at(elem(server_tuple,1),1)),list)
    end

   def spawn_processes(numNodes,start_value,l) do
             if(start_value<=numNodes) do
                l=l++[start(start_value)]
                start_value=start_value+1
                l=spawn_processes(numNodes,start_value,l)
             end
             l
    end

    def creating_topology(topology,list) do

         case topology do

            "full" -> l = get_neighbours(0,"full",list,0,[])
                      IO.inspect l

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
        {:ok,pid} = GenServer.start_link(__MODULE__,[],name: String.to_atom(to_string(start_value)))
        pid
    end

    #Server Side Implementation
    def init() do
        # First is Rumor
        {:ok,%{:count => 0,:list_of_neighbours =>[],:topology => nil }}
    end

    def handle_cast({:got,msg},state) do
        IO.puts msg;
        {:noreply,state}
    end



end