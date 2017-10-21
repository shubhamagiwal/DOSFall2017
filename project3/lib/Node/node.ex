defmodule Project3.Node do
use GenServer
    
    #Generate Node process
    def start(random_node_id) do
        # Here Node Space is 2^128-1
        #node_Id=Project3.LibFunctions.randomizer(37,:numeric);
        hash=:crypto.hash(:sha256, to_string(random_node_id)) |> Base.encode16
        IO.puts "#{inspect random_node_id} - #{inspect hash}"
        {:ok,pid} = GenServer.start_link(__MODULE__,hash)
        {pid,hash,random_node_id}
    end

    #Server Side Implementation
    def init(args) do  
        {:ok,%{:node_id => args}}
    end

end
