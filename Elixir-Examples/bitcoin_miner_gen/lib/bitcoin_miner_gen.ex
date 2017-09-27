defmodule BitcoinMinerGen do
  @moduledoc """
  Documentation for BitcoinMinerGen.
  """

  @doc """
  Hello world.

  ## Examples

      iex> BitcoinMinerGen.hello
      :world

  """
  def main(args \\ []) do
       case BitcoinMinerGen.Libfunctions.ip_check(to_string(args)) do
          :true -> IO.puts " Need to start the client"# Start the client
          :false -> IO.puts " Need to start the server"
                    BitcoinMinerGen.Libfunctions.get_ip(to_string(args)) |> 
                    BitcoinMinerGen.Server.start_server_node
          #Start the Server
       end 
  end

end
