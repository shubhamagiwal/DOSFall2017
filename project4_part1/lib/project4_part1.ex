defmodule Project4Part1 do
  def main(args \\ []) do

        if(length(args)==1) do
            #Create the server Processs
            Project4Part1.LibFunctions.get_ip_address(args)|>Project4Part1.Boss.start_boss
            loop()
        else
            IO.puts "Enter the arguments as mentioned in the documentation"
        end 
end

def loop() do
   loop()
end

end
