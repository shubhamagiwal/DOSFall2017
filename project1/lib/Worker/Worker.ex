defmodule Project1.Worker do
        def get_bit_coins(k, start_value, end_value,pid) do
            value = to_string(k)
            if (start_value<end_value) do
            random_string = to_string(to_string("shubhamagiwal92;")<>to_string(start_value))
            hash=:crypto.hash(:sha256,random_string) |> Base.encode16
            status=String.slice(hash,0..String.to_integer(value)-1) |> check ;
                        if status do
                                send(:global.whereis_name(:server),{:bitcoinfound,random_string,hash})
                        end
            start_value=start_value+1      
            get_bit_coins(k, start_value, end_value,pid)      
            else if(start_value>=end_value) do
                #IO.inspect pid 
                send(pid,{:getnew,self})
                loop
            end   
            get_bit_coins(k, start_value, end_value,pid)
          end   
        end

        def loop do
            Process.flag(:trap_exit, true)
            receive do
                {:sendnew,k, start_value, end_value,pid} -> get_bit_coins(k, start_value, end_value,pid)
                {:badarg,_value} ->  Process.exit(self,:kill)  
             end

             loop
        end

          def check(partOfHash) do
              Enum.all?(String.graphemes(partOfHash),fn(x) -> x=="0" end);
          end

          def printBitCoin(status,randomString,hash) do
              case status do
                   true-> {randomString,hash} #IO.puts "#{randomString}  #{hash}"
                    _-> :ok
              end 
          end

end