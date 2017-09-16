defmodule Project1.Libfunctions do

    def get_ip_address(k) do
     {:ok,[{ipadd1,_,_},{_,_,_}]}=:inet.getif()
     ipaddress= ipadd1|> Tuple.to_list |> Enum.join(".") 
     {ipaddress,k}
    end

    def ip_address_check(value) do
        case :inet.parse_ipv4strict_address(to_charlist((value))) do
              {:ok,ip}-> :true
              {:error,:einval}-> :false     
        end
    end 

end