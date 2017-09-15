defmodule Project1.Libfunctions do

    def getIpAddress() do
     {:ok,[{ipadd1,_,_},{_,_,_}]}=:inet.getif()
     ipaddress= ipadd1|> Tuple.to_list |> Enum.join(".") 
    end

end