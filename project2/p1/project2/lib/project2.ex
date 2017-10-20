defmodule Project2 do
  
  def main(args\\[]) do
      Project2.LibFunctions.get_ip_address(args) |> Project2.Server.start_server_node
      loop()
  end

  def loop() do
    loop()
  end

end
