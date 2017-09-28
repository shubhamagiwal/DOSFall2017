defmodule BitcoinMinerGen.Server do
use GenServer
    @workload 1000
    @startvalue 0
    
    def start_server_node(tuple) do
       server_name=String.to_atom(to_string("server@")<>elem(tuple,0))
       {:ok,server_pid}=Node.start(server_name)
       cookie=Application.get_env(:bitcoinMinerGen, :cookie)
       Node.set_cookie(cookie)
       :global.register_name(:server,self())
       Node.spawn(Node.self,fn -> BitcoinMinerGen.Server.start(elem(tuple,1)) end);       
    end

    #Client Side Implementation 

    def start(k) do
        {:ok,_} = GenServer.start_link(__MODULE__,[k],name: Server)
        GenServer.cast(Server,:sendRequest)
        loop();
    end

    #Server Side Implementation
    def init(args) do
        workload_start=@startvalue;
        workload_end=@startvalue+@workload;
        {:ok,{workload_start,workload_end,Enum.at(args,0)}}
    end

    def handle_call(:get_work_load,_from,state_tuple) do
      workload_start=elem(state_tuple,0)+@workload;
      workload_end=elem(state_tuple,1)+@workload;
      IO.puts  to_string(workload_start)
      IO.puts  to_string(workload_end)
      {:reply,nil,{workload_start,workload_end,elem(state_tuple,2)}}
    end

    def handle_cast(:sendRequest,state_tuple)do
        spawn(fn->BitcoinMinerGen.Worker.get_bit_coins(elem(state_tuple,2),elem(state_tuple,0),elem(state_tuple,1),Server,Node.self()) end)
        # BitcoinMinerGen.Worker.call_back_server(Server,Node.self())
        {:noreply,state_tuple}
    end

     def handle_cast({:got,random_string,hash},state_tuple)do
        IO.puts "#{random_string}  #{hash}"
        {:noreply,state_tuple}
    end


     def handle_cast({:new_workload,worker_process_id},state_tuple)do
        workload_start=elem(state_tuple,0)+@workload;
        workload_end=elem(state_tuple,1)+@workload;
        IO.puts  to_string(workload_start)
        IO.puts  to_string(workload_end)
        send(worker_process_id,{:new_workLoad,workload_start,workload_end,elem(state_tuple,2),Server,Node.self()})
        {:noreply,{workload_start,workload_end,elem(state_tuple,2)}}
    end

    def loop() do
        loop()
    end


end