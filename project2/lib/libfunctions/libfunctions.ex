defmodule Project2.LibFunctions do

    def inital_check_for_arguments(args)do

            case Enum.count(args)<3 do
                    true -> IO.puts "Number of arguments is less than 3. Please provide the right number of arguements"
                            Process.exit(self, :normal)
                    false -> Project2.LibFunctions.no_of_nodes_check(args)
             end
    end

     def get_ip_address(args) do
        {:ok,[{ipadd1,_,_},{_,_,_}]}=:inet.getif()
        ipaddress= ipadd1|> Tuple.to_list |> Enum.join(".") 
        {ipaddress,args}
    end
end
