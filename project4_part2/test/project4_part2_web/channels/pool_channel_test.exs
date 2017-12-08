defmodule Project4Part2Web.PoolChannelTest do
  use Project4Part2Web.ChannelCase, async: true

  alias Project4Part2Web.PoolChannel
  require IEx

  setup do
    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(PoolChannel, "pool:client1")


    {:ok, socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "create_user", %{"id" => "1"}
    assert_reply ref, :ok
  end

  # test "shout broadcasts to pool:lobby", %{socket: socket} do
  #   push socket, "shout", %{"hello" => "all"}
  #   assert_broadcast "shout", %{"hello" => "all"}
  # end

  # test "broadcasts are pushed to the client", %{socket: socket} do
  #   broadcast_from! socket, "broadcast", %{"some" => "data"}
  #   assert_push "broadcast", %{"some" => "data"}
  # end
end
