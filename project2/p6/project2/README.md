# DOSFall2017
#### Project 2 Gossip Simulator
This is a distributed gossip simulator made on Elixir.

#### Instructions for running the program:
1. cd into project2 directory. Use command `cd DOSFall2017/project2` and hit return.
2. Once in project2 directory, run command `mix escript.build`. This will build an executable file ignore warnings if any.
3. After successfull compilation please follow the command stated below:<br>
    `./project2	  number_of_nodes		type_of_topology	type_of_algorithm`<br>
    > number_of_nodes: integer values (0-2000)<br>
    > type_of_topology: line || 2D || imp2D || full NOTE: Please be carefull about the letter casing<br>
    > type_of_algorithm: gossip | push-sum <br>
    
#### Instructions for bonus part:
1. Follow steps 1 & 2 from above.
2. After successfull compilation please follow the command stated below:<br>
    `./project2	  number_of_nodes		type_of_topology	type_of_algorithm percentage_nodes_to_kill`<br>
    > number_of_nodes: integer values (0-2000)<br>
    > type_of_topology: line || 2D || imp2D || full NOTE: Please be carefull about the letter casing<br>
    > type_of_algorithm: gossip | push-sum <br>
    > percentage_nodes_to_kill: float value (0-100)
    
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
Input: `./project2 1000 2D push-sum 50`<br>
Output: <br>
`....build topology`<br> `....start protocol` <br> `Time the program ran for is 65 milliseconds `

##### For other references see report.pdf and bonus_report.pdf


