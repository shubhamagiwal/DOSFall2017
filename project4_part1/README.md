# Project-4 Part-2 DOS Fall 2017
## Twitter Tester/Simulator With Phoenix Websockets

#### Team Members
Shubham Agiwal 20562669, Karan Sharma 00174451

### Abstract
This is a Twitter clone and a client tester/simulator built using Elixir and phoenix. We have a server which is the main server which is used as a datastore. This server contains all the data about the tweets, retweets, hashtags and mentions. The datastore is maintained using ETS(Erlang Term Storage). The server is a central engine which is used to distribute tweets. Web socket interface for Twitter engine – with functionalities for Account registration, sending tweets, tweets with hashtags and mentions, re-tweets, querying and live delivery of tweets.  
### Runtime Commands
> 1. Extract the contents of the zip file. <br>
> 2. CD into the relevant directory using command `cd project4_part2` and run `mix escript.test --trace`<br>


### Largest network for test
 We have tested our application for 100 nodes.
 
#### Sample Input/Output
Input ->`mix test --trace`<br>
Output-> Server: <br>
{"topic":"pool:client","ref":"1","payload":{"response":"tweeter:user83 has tweeted the given tweet "njsvyiap2uzf2wx036ow2sxyp7w4ul7a #6hccbkpe" with the given hashtag "#6hccbkpe""},"join_ref":"null","event":"tweet"}<br>
{"topic":"pool:client","ref":"1","payload":{"response":"tweeter:user84 has tweeted the given tweet "0pj73zsji5s4ifttetg6gwjt6gxx4bgp #aejvel3j" with the given hashtag "#aejvel3j""},"join_ref":"null","event":"tweet"}<br>
{"topic":"pool:client","ref":"1","payload":{"response":"tweeter:user85 has tweeted the given tweet "u8mfzg4rcvk275llmt2aiopbqflan30a #qdcludxn" with the given hashtag "#qdcludxn""},"join_ref":"null","event":"tweet"}<br>








