defmodule Project4Part1 do
  def main(args \\ []) do

        if(length(args)==2) do
            #Create the server Processs
            Project4Part1.LibFunctions.get_ip_address(args)|>Project4Part1.Boss.start_boss
            loop()
        else if(length(args)==3) do
             Project4Part1.Node.start_client(args) |> Project4Part1.Node.connect_to_server
             loop()
        else
            IO.puts "Enter the arguments as mentioned in the documentation"
            end
        end 
end

def loop() do
   loop()
end

end
