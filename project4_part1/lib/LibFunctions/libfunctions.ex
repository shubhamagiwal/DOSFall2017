defmodule Project4Part1.LibFunctions do

# get the IP address of the machine
     def get_ip_address(args) do
        {:ok,[{ipadd1,_,_},{_,_,_}]}=:inet.getif()
        ipaddress= ipadd1|> Tuple.to_list |> Enum.join(".")
        IO.inspect ipaddress 
        {ipaddress,args}
    end

#https://gist.github.com/ahmadshah/8d978bbc550128cca12dd917a09ddfb7
 def randomizer(length, type \\ :all) do
    alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    numbers = "0123456789"

    lists =
      cond do
        type == :alpha ->String.downcase(alphabets)
        type == :numeric -> numbers
        type == :upcase -> alphabets
        type == :downcase -> String.downcase(alphabets)
        true -> String.downcase(alphabets) <> numbers
      end
      |> String.split("", trim: true)

    do_randomizer(length, lists)
  end

  @doc false
  defp get_range(length) when length > 1, do: (1..length)
  defp get_range(length), do: [1]

  @doc false
  defp do_randomizer(length, lists) do
    get_range(length)
    |> Enum.reduce([], fn(_, acc) -> [Enum.random(lists) | acc] end)
    |> Enum.join("")
  end

end
