defmodule Project1.Libfunctions do

    def getIpAddress(value) do
     {:ok,[{ipadd1,_,_},{_,_,_}]}=:inet.getif()
     ipaddress= ipadd1|> Tuple.to_list |> Enum.join(".") 
     tup = {ipadd1|> Tuple.to_list |> Enum.join("."), value}
    end

end