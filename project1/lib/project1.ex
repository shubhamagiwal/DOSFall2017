defmodule Project1 do

  def ip_address_check(value) do

      case :inet.parse_address(to_charlist((value))) do
            {:ok,ip}-> :true
            {:error,:einval}-> :false
           
      end

  end 

  def main(args \\ []) do
       ip_address_valid= to_string(args) |> ip_address_check #Check for the IP address validity
       
    end

end
