defmodule Examplemix do
   use GenServer

  def start_link do
      GenServer.start_link(__MODULE__,:ok)
  end

  def init(:ok) do
     IO.puts "Genserver is being called"
     {:ok,%{}}
  end

  def add(pid,name) do
      GenServer.cast(pid,{:add,name})
  end

  def remove(pid,name)do
      GenServer.cast(pid,{:remove,name})
  end

  def print(pid) do
      GenServer.call(pid,:team)
  end

  def convertToSha256(pid,name)do
      GenServer.call(pid,{:hash,name})
  end

  def handle_cast({:add,name},state) do
      new_state=Map.put(state,name,name);
      {:noreply,new_state}
  end

  def handle_cast({:remove,name},state) do
      new_state=Map.delete(state,name)
      {:noreply,new_state}
  end

  def handle_cast({:hash,name},state)do
      hashValue = :crypto.hash(:sha256, "whatever") |> Base.encode16
      new_state=Map.put(state,name,hashValue)
      {:noreply,new_state}
  end

  def handle_call(:team,_from,state)do
      {:reply,state,state}
  end

  def handle_call({:hash,name},_from,state)do
      hashValue = :crypto.hash(:sha256, name) |> Base.encode16
      new_state=Map.put(state,name,hashValue)
      {:reply,new_state,new_state}
  end

 
  def main(args \\ []) do
     #IO.puts "Hello world"
     #IO.puts "Hello World #{args}"
     #{:ok, ifs} = :inet.getif()
     #{:ok,basic_pid}=Examplemix.start_link
     #IO.inspect Examplemix.convertToSha256(basic_pid,"Shubham")
     #IO.inspect Examplemix.convertToSha256(basic_pid,"karan")
     #IO.puts "The list of names before removal"
     #IO.inspect Examplemix.print(basic_pid)
     #Map.values(Examplemix.print(basic_pid)) |> Enum.each( fn(x) -> IO.puts x end)
     #Enum.each(Map.values(Examplemix.print(basic_pid)),fn(x)-> IO.puts x end)
     #IO.puts "The list of name after removal"
     #Examplemix.remove(basic_pid,"Shubham")
     #Map.values(Examplemix.print(basic_pid)) |> Enum.each( fn(x) -> IO.puts x end)
     #Enum.each(Map.values(Examplemix.print(basic_pid)),fn(x)-> IO.puts x end)     
     #IO.inspect(ifs)
     #IO.inspect(:inet.ip_address)
     #IO.inspect(basic_pid)

     {:ok,[{ipadd1,_,_},{_,_,_}]}=:inet.getif()
     IO.puts ipadd1|> Tuple.to_list |> Enum.join(".") 
  end


end
