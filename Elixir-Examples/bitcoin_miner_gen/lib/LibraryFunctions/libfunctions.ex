defmodule  BitcoinMinerGen.Libfunctions do
    
    def ip_check(args) do
         case :inet.parse_ipv4strict_address(to_charlist((args))) do
              {:ok,ip}-> :true
              {:error,:einval}-> :false     
        end
    end

     def get_ip(k) do
        {:ok,[{ipadd1,_,_},{_,_,_}]}=:inet.getif()
        ipaddress= ipadd1|> Tuple.to_list |> Enum.join(".") 
        {ipaddress,k}
    end


end