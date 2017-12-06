defmodule Project4Part2Web.PoolChannel do
    use Project4Part2Web, :channel
    use GenServer

    def join("pool:client"<>client_number, _params, socket)  do
        
        IO.inspect socket
        IO.inspect self()
        
        #client_number=String.to_integer(client_number)
        IO.inspect client_number

        {:ok, socket}
    end

end