defmodule Examplemix.Server do

    def start_link do
        {:ok,[{ipadd1,_,_},{_,_,_}]}=:inet.getif()
        ipaddress= ipadd1|> Tuple.to_list |> Enum.join(".") 
        {:ok,pid}=Node.start(String.to_atom("awesome@"<>to_string(ipaddress)))
        Node.set_cookie(Node.self(),String.to_atom("awesome"))
        IO.puts Node.self();
        IO.puts "Genserver is being called"
        #sha256Generator({:false,to_string(1)})
        #pid1=Node.spawn(Node.self(),fn-> sha256Generator({:false,to_string(1)})end)
        #IO.puts to_string(pid1)
        send(pid,{:hashValue,:false,1})
        receive do
            {:hashValue,status,value} -> sha256Generator({status,value})
        end
     end

    def sha256Generator({status,value}) do
       randomString=(to_string("shubhamagiwal92")<>SecureRandom.base64(12));       
       hash=:crypto.hash(:sha256,randomString) |> Base.encode16
       if to_string(status)==to_string("false") do
            status=String.slice(hash,0..String.to_integer(value)-1) |> check ;
            printBitCoin(status,randomString,hash)
            sha256Generator({:false,value})
       end
       sha256Generator({:false,value})
    end

  def check(partOfHash) do
      Enum.all?(String.graphemes(partOfHash),fn(x) -> x=="0" end);
  end

  def printBitCoin(status,randomString,hash) do
      case status do
           true->  IO.puts "#{randomString}  #{hash}"
            _-> :ok
      end 
  end

end
