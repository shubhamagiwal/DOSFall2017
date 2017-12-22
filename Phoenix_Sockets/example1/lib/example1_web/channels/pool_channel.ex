defmodule Example1Web.PoolChannel do
    use Project4Part2Web, :channel
    use GenServer

    def join("pool:client"<>client_number, _params, socket)  do
        
        #IO.inspect socket
        #IO.inspect self()
        clientName=String.to_atom("tweeter@user"<>client_number)
        Process.register(self(),clientName)
        password=Project4Part2.LibFunctions.randomizer(8,true)
        {:ok, socket}
    end

    def handle_in("update",  %{:name => clientname}, socket) do
        IO.inspect clientname
        {:noreply, socket}
      end

end