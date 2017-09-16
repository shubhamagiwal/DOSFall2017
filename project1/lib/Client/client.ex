defmodule Project1.Client do
    
    def start_client(ip_address)do
        clientName=generate_name(ip_address)
        {:ok,clientpid}=Node.start(clientName)
        cookie=Application.get_env(:project1, :cookie)
        Node.set_cookie(cookie)
        tuple={Node.self,ip_address}
    end

    def connect_to_server(tuple)do
        IO.inspect Node.connect(String.to_atom(to_string("server@"<>elem(tuple,1)))); 
        IO.inspect Node.list() 
        :global.sync()
        #IO.inspect :global.whereis_name(:server);
        send(:global.whereis_name(:server),{:ok,self})
        receive do
            {:ok,k}-> IO.puts to_string(k)
        end
    end

    def generate_name(ipaddress) do
        machine = to_string("localhost")
        hex = :erlang.monotonic_time() |>
          :erlang.phash2(256) |>
          Integer.to_string(16)
        String.to_atom("#{machine}-#{hex}@#{ipaddress}")
      end

    def clientlister() do
        receive do
            {:ok,k}-> IO.puts k
        end
    end

end