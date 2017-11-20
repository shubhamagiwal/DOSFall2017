defmodule Project3 do

 def main(args \\ []) do

        if(length(args)==2) do
            #Create the server Processs
            Project3.LibFunctions.get_ip_address(args)|>Project3.Boss.start_boss
            loop()
        else
            IO.puts "Enter the arguments as mentioned in the documentation"
        end 
end

def loop() do
   loop()
end

end
