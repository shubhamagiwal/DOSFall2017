defmodule Examplemix do

#  def main(args \\ []) do

#      actor =spawn(__MODULE__,:sha256spawn,[]);
#      send(actor,{:ok,to_string(1)})
#      #actor=spawn_link(__MODULE__,:world,[]);
#      IO.inspect actor 
#      #IO.puts "Hello world"
#      #IO.puts "Hello World #{args}"
#      #{:ok, ifs} = :inet.getif()
#      #{:ok,basic_pid}=Examplemix.start_link
#      #IO.inspect Examplemix.convertToSha256(basic_pid,"Shubham")
#      #IO.inspect Examplemix.convertToSha256(basic_pid,"karan")
#      #IO.puts "The list of names before removal"
#      #IO.inspect Examplemix.print(basic_pid)
#      #Map.values(Examplemix.print(basic_pid)) |> Enum.each( fn(x) -> IO.puts x end)
#      #Enum.each(Map.values(Examplemix.print(basic_pid)),fn(x)-> IO.puts x end)
#      #IO.puts "The list of name after removal"
#      #Examplemix.remove(basic_pid,"Shubham")
#      #Map.values(Examplemix.print(basic_pid)) |> Enum.each( fn(x) -> IO.puts x end)
#      #Enum.each(Map.values(Examplemix.print(basic_pid)),fn(x)-> IO.puts x end)     
#      #IO.inspect(ifs)
#      #IO.inspect(:inet.ip_address)
#      #IO.inspect(basic_pid)

#     #  {:ok,[{ipadd1,_,_},{_,_,_}]}=:inet.getif()
#     #  ipaddress= ipadd1|> Tuple.to_list |> Enum.join(".") 
#     #  IO.puts "awesome@"<>to_string(ipaddress)
#     #  {:ok,pid}=Node.start(String.to_atom("awesome@"<>to_string(ipaddress)))
#     #  IO.inspect()
#     #  IO.inspect Node.self()
#     #  IO.inspect Node.set_cookie(Node.self(),String.to_atom("awesome"))

#     #     Examplemix.Server.start_link
#     #     IO.inspect Node.ping(String.to_atom("awesome@10.136.44.143"));
#    end

# #    use GenServer

# #   def start_link do
# #       GenServer.start_link(__MODULE__,:ok)
# #   end

# #   def init(:ok) do
# #      {:ok,[{ipadd1,_,_},{_,_,_}]}=:inet.getif()
# #      ipaddress= ipadd1|> Tuple.to_list |> Enum.join(".") 
# #      {:ok,pid}=Node.start(String.to_atom("awesome@"<>to_string(ipaddress)))
# #      Node.set_cookie(Node.self(),String.to_atom("awesome"))
# #      IO.puts "Genserver is being called"
# #      {:ok,%{}}
# #   end

# #   def add(pid,name) do
# #       GenServer.cast(pid,{:add,name})
# #   end

# #   def remove(pid,name)do
# #       GenServer.cast(pid,{:remove,name})
# #   end

# #   def print(pid) do
# #       GenServer.call(pid,:team)
# #   end

# #   def convertToSha256(pid,name)do
# #       GenServer.call(pid,{:hash,name})
# #   end

# #   def handle_cast({:add,name},state) do
# #       new_state=Map.put(state,name,name);
# #       {:noreply,new_state}
# #   end

# #   def handle_cast({:remove,name},state) do
# #       new_state=Map.delete(state,name)
# #       {:noreply,new_state}
# #   end

# #   def handle_cast({:hash,name},state)do
# #       hashValue = :crypto.hash(:sha256, "whatever") |> Base.encode16
# #       new_state=Map.put(state,name,hashValue)
# #       {:noreply,new_state}
# #   end

# #   def handle_call(:team,_from,state)do
# #       {:reply,state,state}
# #   end

# #   def handle_call({:hash,name},_from,state)do
# #       hashValue = :crypto.hash(:sha256, name) |> Base.encode16
# #       new_state=Map.put(state,name,hashValue)
# #       {:reply,new_state,new_state}
# #   end

# #   def start_distributed(appname) do
# #     unless Node.alive?() do
# #       local_node_name = generate_name(appname)
# #       {:ok, _} = Node.start(local_node_name)
# #     end
# #     cookie = Application.get_env(appname, :cookie)
# #     Node.set_cookie(cookie)
# #   end

# #   def generate_name(appname) do
# #     machine = Application.get_env(appname, :machine)
# #     IO.inspect machine
# #     hex = :erlang.monotonic_time() |>
# #       :erlang.phash2(256) |>
# #       Integer.to_string(16)
# #     IO.puts String.to_atom("#{appname}-#{hex}@#{machine}")
# #   end

#     def sha256Generator(value) do
#        randomString=(to_string("shubhamagiwal92")<>SecureRandom.base64(12)); 
#        hash=:crypto.hash(:sha256,randomString) |> Base.encode16
#        status=String.slice(hash,0..String.to_integer(value)-1) |> check ;
#        printBitCoin(status,randomString,hash)
#        sha256Generator(value)
#     end

#   def check(partOfHash) do
#       Enum.all?(String.graphemes(partOfHash),fn(x) -> x=="0" end);
#   end

#   def printBitCoin(status,randomString,hash) do
#       case status do
#            true->  IO.puts "#{randomString}  #{hash}"
#             _-> :ok
#       end 
#   end
 

#  def sha256spawn()do
#     receive do
#     {:ok,k}->sha256Generator(k)
#     end
#  end

def main(args \\ []) do
     for p <- 1..32 do
     	send(spawn(__MODULE__,:sha256spawn,[]),{:ok,to_string(1)})
     end
       do_not_exit
     
   end

    def sha256Generator(value) do
       randomString=(to_string("shubhamagiwal92")<>SecureRandom.base64(12))
       hash=:crypto.hash(:sha256,randomString) |> Base.encode16
       status=String.slice(hash,0..String.to_integer(value)-1) |> check
       printBitCoin(status,randomString,hash)
       sha256Generator(value)
    end

  def check(partOfHash) do
      Enum.all?(String.graphemes(partOfHash),fn(x) -> x=="0" end);
  end

  def printBitCoin(status,randomString,hash) do
      case status do
           true->  IO.puts "#{randomString}  #{hash}"
           false-> ""
      end 
  end

def do_not_exit do
	do_not_exit
end
 

 def sha256spawn()do
    receive do
    {:ok,k}->sha256Generator(k)
    end
 end
end



