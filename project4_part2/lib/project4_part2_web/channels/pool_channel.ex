defmodule Project4Part2Web.PoolChannel do
  
  use Project4Part2Web, :channel
  use GenServer

  def join("pool:client"<>client_number, _auth_message, socket)  do
      {:ok,socket}
  end

  def handle_in("create_user",%{"id"=> id},socket)do
      #clientName=String.to_atom("tweeter@user"<>to_string(id))
      password=Project4Part2.LibFunctions.randomizer(8,true)        
      clientName=Project4Part2.Node.start_client(id,socket)
      GenServer.cast(Boss_Server,{:created_user,clientName,password,id,socket})
      {:reply, :ok, socket}
  end

  # def handle_in("subscribe",)

  def handle_in("tweet",  %{
      "name_of_user" => client_name,
      "hashTag" => hashTag,
      "tweet" => tweet,
      "reference" => reference,
      "isFreshUser" => isFreshUser
  }, socket) do
      #IO.inspect "I am here "
      GenServer.cast(Boss_Server,{:got_tweet,tweet,hashTag,client_name,reference,isFreshUser,socket})
      {:reply,:ok,socket}
      #{:noreply, socket}
    end

    def handle_in("login",%{"client_name" => client_name},socket)do
      GenServer.cast(Boss_Server,{:query,client_name})
      {:reply,:ok,socket}
    end

    def handle_in("mention_tweet",  %{
      "name_of_user" => client_name,
      "hashTag" => hashTag,
      "tweet" => tweet,
      "reference" => reference
  }, socket) do
      GenServer.cast(Boss_Server,{:got_mention_tweet,client_name,tweet,hashTag,reference,socket})
      {:reply,:ok,socket}
    end

    def handle_in("got_tweet",  %{"original_tweeter" => original_tweeter, "tweet" => tweet, "hashTag" => hashTag, "receiver" => receiver}, socket) do
      IO.puts " I am here "
      IO.puts "#{inspect receiver} :Got a tweet #{inspect tweet} from  #{inspect original_tweeter} using socket #{inspect socket}"
      {:reply,:ok,socket}
    end

    def handle_in("got_mention_tweet",  
    %{"reference"=> reference, "name_of_user"=> name_of_user, "tweet"=>tweet, "random_hashtag"=> random_hashtag}, socket) do
      IO.puts "#{inspect reference} :Got a tweet #{inspect tweet} from  #{inspect name_of_user} using socket #{inspect socket}" 
      {:reply,:ok,socket}
    end

    def handle_in("got_retweet",  
    %{ "tweet" => tweet, "hashTag" => hashtag, "receiver"=> receiver,"client_name_retweeting" => client_name_retweeting  }, socket) do
      IO.puts "#{inspect receiver} :Got a retweet #{inspect tweet} from  #{inspect client_name_retweeting} using socket #{inspect socket}" 
      {:reply,:ok,socket}
    end

  

end