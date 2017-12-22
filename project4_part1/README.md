# Project-4 Part DOS Fall 2017
## Twitter Tester/Simulator

#### Team Members
Shubham Agiwal 20562669, Karan Sharma 00174451

### Abstract
This is a Twitter clone and a client tester/simulator built using Elixir. We have a server which is the main server which is used as a datastore. This server contains all the data about the tweets, retweets, hashtags and mentions. The datastore is maintained using ETS(Erlang Term Storage). The server is a central engine which is used to distribute tweets.In our simulation one can create multiple clients and we can launch multiple user processes on each client. 

### Runtime Commands
> 1. Extract the contents of the zip file. <br>
> 2. CD into the relevant directory using command `cd project4_part1` and run `mix escript.build`<br>
> 3. To run the server, run the following command                                                                             `./project4_part1 server number_of_clients` the number_of_clients parameter can be set to any integer from 1 to 10<br>
> 4. To run the client, run the following  command  in another window                                                        `./project4_part1 client server_ip_address number_of_users`.
> 5. The server_ip_address can be found on the Server window of terminal and the number of users can be a natural number.  
Note:The number of client windows that you open on the terminal should equal to the number_of_clients parameter that you passed when launching the server. 

### Largest network for test
 We have tested our application for upto 3 clients with 1000 user processes each.
 
#### Sample Input/Output
Input -> Server: `./project4_part1 server 1`<br>
Output-> Server: <br>
`"10.20.237.5"`<br>
`:"server@10.20.237.5"`<br>

Input -> Client: `./project4_part1 client 10.20.237.5 100`<br>
Output -> Client: <br>
`:tweeter@user96 of :"localhost-17@10.20.237.5":Got a tweet "jswuwxhkqkyfjimcszdpshmrujlgjwde#yjlkyju1" from  :tweeter@user57 of  :"localhost-17@10.20.237.5"` <br>
`:tweeter@user19 of :"localhost-17@10.20.237.5":Got a tweet "pscoamhhbjknhgtcddzibrerveprnwsr#5e97j5t8" from  :tweeter@user78 of  :"localhost-17@10.20.237.5"` <br>
`:tweeter@user60 of :"localhost-17@10.20.237.5":Got a tweet "sksmfjrdxfgugixukxhtoparruumrzyt#d2ne2p2d" from  :tweeter@user62 of  :"localhost-17@10.20.237.5"` <br>
`:tweeter@user88 of :"localhost-17@10.20.237.5":Got a tweet "ipohqkwypudcttgmjhnhrhojfdgskumb#3fwiycac" from  :tweeter@user63 of  :"localhost-17@10.20.237.5"` <br>




