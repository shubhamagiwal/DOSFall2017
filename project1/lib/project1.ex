defmodule Project1 do
  use GenServer

  def ip_address_check(value) do
      case :inet.parse_address(to_charlist((value))) do
            {:ok,ip}-> {:true,to_string(value)}
            {:error,:einval}-> {:false,to_string(value)}      
      end
  end 

  def sha256Generator({status,value}) do
       IO.puts :crypto.hash(:sha256,(to_string("shubhamagiwal92")<>SecureRandom.base64(8))) |> Base.encode16
  end

  def main(args \\ []) do
       ip_address_valid= to_string(args) |> ip_address_check |> sha256Generator #Check for the IP address validity and then pass it to sha256 generator       
    end

end
