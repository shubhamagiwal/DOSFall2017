## Peer to peer pastry implemented in elixir
##### Team members
Shubham Agiwal 20562669, Karan Sharma 00174451<br>

##### What is working?
This is a p2p pastry protocol implemented on elixir. In our implementation we are building a pastry and successfully sending the messages and priniting the average hop count<br>
We have also implemented the failure model where certain percentage of nodes can is killed and then the efficiency of pastry is being tested.<br>

##### Largest network of nodes
The largest network that we ran our code on was for 5000 nodes and 10 requests for each peer.<br>

##### To run the project3 commands
1. Unzip the contents of the package and do `cd project3`<br>
2. Run `mix deps.get` followed by `mix escript.build`<br>
3. Run `./project3 {number_of_nodes} {number of requests}` number_of_nodes  and number_of_requests can be whole numbers.


##### Sample input-output
> project3<br>
Input: `./project3 100 10`<br>
Output: The average hop count is 1.3610<br>

>project3-bonus<br>
Input: `./project3 800 25 20`<br>
Output: The average hop count is 1.2736<br>
