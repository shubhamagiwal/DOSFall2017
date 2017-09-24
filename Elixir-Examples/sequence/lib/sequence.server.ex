defmodule Sequence.Server do
  use GenServer

  def start_link(number)do
    GenServer.start_link(__MODULE__,number)
  end

  def next(pid) do
    GenServer.call(pid,:nextnumber)
  end

  def increment_number(delta,pid) do
    GenServer.cast(pid,{:increment_number,delta})
  end

  def handle_call(:nextnumber,_from,current_number)do
    {:reply,current_number+1,current_number+1}
  end

  def handle_cast({:increment_number,delta},current_number)do
    {:noreply,current_number+delta}
  end

end
