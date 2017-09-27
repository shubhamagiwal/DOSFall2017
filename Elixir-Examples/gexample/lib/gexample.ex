defmodule Gexample do
use GenServer

#Client Side implementation
 def start_link do
      GenServer.start_link(__MODULE__,[])
end

def get_msgs(pid) do
    GenServer.call(pid,:get_msgs);
end

def add_msg(pid,msg) do
    GenServer.cast(pid,{:add_msg,msg});
end

#Server side Implementation
def init(msgs) do
    {:ok,msgs}
end

def handle_call(:get_msgs,_from,msgs) do
  {:reply,msgs,msgs}
end

def handle_cast({:add_msg,msg},msgs) do
    {:noreply,[ msg | msgs ]}
end

  
  def main(args\\[]) do

    # Basic Genserver implementation for a calculator
    {:ok,pid}= Gexample.start_link
    add_msg(pid,"I am here")
    add_msg(pid,"I am here and there")
    add_msg(pid,"I am here and I am awesome")
    IO.inspect get_msgs(pid)
    loop()

  end

  def loop() do
    loop()
  end

end
