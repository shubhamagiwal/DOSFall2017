defmodule Project1 do
   
    def main(args \\ []) do

        case Project1.Libfunctions.ip_address_check(to_string(args)) do
            :true-> IO.puts "Go to client"# Go to client
            :false-> Project1.Libfunctions.get_ip_address(to_string(args)) |> Project1.Server.start |> Project1.Worker.startWorker
        end

        donotexit
    end

    def donotexit do
        donotexit
    end

end
