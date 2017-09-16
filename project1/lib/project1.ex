defmodule Project1 do
#  use GenServer

#   def ip_address_check(value) do
#       case :inet.parse_ipv4strict_address(to_charlist((value))) do
#             {:ok,ip}-> {:true,to_string(value)}
#             {:error,:einval}-> {:false,to_string(value)}      
#       end
#   end 

#   def sha256Generator({status,value}) do
#        randomString=(to_string("shubhamagiwal92")<>SecureRandom.base64(12));
#        hash=:crypto.hash(:sha256,randomString) |> Base.encode16
#        if to_string(status)==to_string("false") do
#             status=String.slice(hash,0..String.to_integer(value)-1) |> check ;
#             printBitCoin(status,randomString,hash)
#             sha256Generator({false,value})
#        end
#        sha256Generator({false,value})
#   end

#   def check(partOfHash) do
#       Enum.all?(String.graphemes(partOfHash),fn(x) -> x=="0" end);
#   end

#   def printBitCoin(status,randomString,hash) do
#       case status do
#            true->  IO.puts "#{randomString}  #{hash}"
#             _-> :ok
#       end 
#   end

 
  def main(args \\ []) do
       pid=to_string(args) |> Project1.Libfunctions.getIpAddress |> Project1.Server.start |> Project1.Worker.startWorker
       donotexit
       #ip_address_valid= to_string(args) |> ip_address_check |> sha256Generator #Check for the IP address validity and then pass it to sha256 generator       
  end

  def donotexit do
      donotexit
  end

end
