defmodule Project4Part1.Node do
use GenServer
    
    #Generate Node process
    def start(id_tweeter) do
        name_of_node=String.to_atom("tweeter@user"<>to_string(id_tweeter))
        password=Project4Part1.LibFunctions.randomizer(8,true)
        {:ok,_} = GenServer.start_link(__MODULE__,password,name: name_of_node)
        {name_of_node}
    end

    #Server Side Implementation
    def init(args) do  
        #IO.puts "#{inspect self} #{inspect args}" 
        {:ok,%{:password => args}}
    end

    def handle_cast({:check},state)do
        IO.puts "I am here in #{inspect self()} #{inspect state[:password]}"
        {:noreply,state}
    end

end
