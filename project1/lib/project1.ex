defmodule Project1 do
   
    def main(args \\ []) do

        case Project1.Libfunctions.ip_address_check(to_string(args)) do
            :true-> Project1.Client.start_client(to_string(args)) |> Project1.Client.connect_to_server# Go to client
            :false-> Project1.Libfunctions.get_ip_address(to_string(args)) |> Project1.Server.start |> Project1.Worker.startWorker
        end
    end

end
