# DOSFall2017
#### Project 2 Gossip Simulator
This is a distributed gossip simulator made on Elixir.
###### Team Members
Shubham Agiwal UFID: 20562669<br>
Karan Sharma   UFID: 00174451<br>
###### What is working?
We have made two different implementaions for gossip algorithm and one for push-sum as mentioned in the report. Line, full, 2d and imp2d topologies are working for all the implementations.
###### Largest Network of Nodes
> The largest network of nodes on which we tested all our implementations is 10,000.


#### Instructions for running the program:
1. Once in project2 directory, run command `mix escript.build`. This will build an executable file ignore warnings if any.
3. After successfull compilation please follow the command stated below:<br>
    `./project2	  number_of_nodes		type_of_topology	type_of_algorithm`<br>
    > number_of_nodes: integer values (0-2000)<br>
    > type_of_topology: line || 2D || imp2D || full NOTE: Please be carefull about the letter casing<br>
    > type_of_algorithm: gossip | push-sum <br>
    
#### Instructions for bonus part:
1. Follow step 1 nfrom above.
2. After successfull compilation please follow the command stated below:<br>
    `./project2	  number_of_nodes		type_of_topology	type_of_algorithm {begin_kill | after_kill} percentage_nodes_to_kill`<br>
    > number_of_nodes: integer values (0-2000)<br>
    > type_of_topology: line || 2D || imp2D || full NOTE: Please be carefull about the letter casing<br>
    > type_of_algorithm: gossip | push-sum <br>
    > percentage_nodes_to_kill: integer value (0-100)
    
#### Sample input output<br>
###### gossip<br>
Input: `./project2 1000 2D gossip`<br>
Output: <br>
`....build topology`<br> `....start protocol` <br> `Time the program ran for is 9034 milliseconds `
###### push-sum<br>
Input: `./project2 1000 2D push-sum`<br>
Output: <br>
`....build topology`<br> `....start protocol` <br> `Time the program ran for is 259 milliseconds `
###### bonus<br>
Input: `./project2 1000 2D push-sum begin_kill 50`<br>
Output: <br>
`....build topology`<br> `....start protocol` <br> `Time the program ran for is 43 milliseconds `

###### bonus<br>
Input: `./project2 1000 2D gossip after_kill 50`<br>
Output: <br>
`....build topology`<br> `....start protocol` <br> `Time the program ran for is 4333 milliseconds `

##### For other references see report.pdf and bonus_report.pdf


