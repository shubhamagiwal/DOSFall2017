defmodule Project3 do

 def main(args \\ []) do

        if(length(args)==2) do
            #Create the ser
            loop()
        else
            IO.puts "Enter the arguments as mentioned in the documentation"
        end 
end

def loop() do
   loop()
end

end
