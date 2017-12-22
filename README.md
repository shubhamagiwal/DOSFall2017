# DOS Fall 2017

Projects completed Successfully by Shubham Agiwal (UFID 20562669) and Karan Sharma( UFID 00174451)

## Projects Description

### Project 1 Distributed Bit Coin Miner on Elixir

Bitcoins (see http://en.wikipedia.org/wiki/Bitcoin) are the most popular crypto-currency in common use. At their hart, bitcoins use the hardness of cryptographic hashing (for a reference see http://en.wikipedia.org/wiki/Cryptographic hash function) to ensure a limited “supply” of coins. In particular, the key component in a bitcoin is an input that, when “hashed” produces an output smaller than a target value. In practice, the comparison values have leading 0’s, thus the bitcoin is required to have a given number of leading 0’s (to ensure 3 leading 0’s, you look for hashes smaller than 0x001000... or smaller or equal to 0x000ff.... The hash you are required to use is SHA-256. You can check your version against this online hasher: http://www.xorbin.com/tools/sha256-hash-calculator. For example, when the text “COP5615 is a boring class” is hashed, the value 0xe9a425077e7b492076b5f32f58d5eb6824b1875621e6237f1a2430c6b77e467c is obtained. For the coins you find, check your answer with this calculator to ensure correctness. The goal of this first project is to use Elixir and the actor model to build a good solution to this problem that runs well on multi-core machines.

###  Project 2 Gossip Simulator
As described in class Gossip type algorithms can be used both for group communication and for aggregate computation. The goal of this project is to determine the convergence of such algorithms through a simulator based on actors written in Elixir. Since actors in Elixir are fully asynchronous, the particular type of Gossip implemented is the so called Asynchronous Gossip. Gossip Algorithm for information propagation<br>

The Gossip algorithm:
• <b>Starting</b>: A participant(actor) it told/sent a roumor(fact) by the main process<br>
• <b>Step</b>: Each actor selects a random neighboor and tells it the roumor<br>
• <b>Termination</b>: Each actor keeps track of rumors and how many times it has heard the rumor. It stops transmitting once it has heard the rumor 10 times (10 is arbitrary, you can select other values).<br>

Push-Sum algorithm

• <b>State</b>: Each actor Ai maintains two quantities: s and w. Initially, s = xi = i (that is actor number i has value i, play with other distribution if you so desire) and w = 1<br>
• <b>Starting</b>: Ask one of the actors to start from the main process.<br>
• <b>Receive</b>: Messages sent and received are pairs of the form (s, w). Upon receive, an actor should add received pair to its own corresponding values. Upon receive, each actor selects a random neighbour and sends it a message.<br>
• <b>Send</b>: When sending a message to another actor, half of s and w is kept by the sending actor and half is placed in the message.
• <b>Sum estimate</b>: At any given moment of time, the sum estimate is s/w where s and w are the current values of an actor.<br>
• <b>Termination</b>: If an actors ratio s/w did not change more than 10^-10 in 3 consecutive rounds the actor terminates. WARNING: the values s and w independently never converge, only the ratio does.<br>

The actual network topology plays a critical role in the dissemination speed of Gossip protocols. As part of this project you have to experiment with various topologies. The topology determines who is considered a neighboor in the above algorithms.

•<b> Full Network</b> Every actor is a neighboor of all other actors. That is, every actor can talk directly to any other actor.<br>
• <b>2D Grid</b> Actors form a 2D grid. The actors can only talk to the grid neigboors.<br>
• <b>Line: Actors</b> are arranged in a line. Each actor has only 2 neighboors (one left and one right, unless you are the first or last actor).<br>
• <b>Imperfect 2D Grid</b> Grid arrangement but one random other neighboor is selected from the list of all actors (4+1 neighboors).<br>

###  Project 3 Pastry Implementation

We talked extensively in class about the overlay networks and how they can be used to provide services. The goal of this project is to implement in Elixir using the actor model the Pastry protocol and a simple object access service to prove its usefulness.The specification of the Pastry protocol can be found in the paper Pastry: Scalable, decentralized object location and routing for large-scale peer-topeer systems. by A. Rowstron and P. Druschel. You can find the paper at (http://rowstron.azurewebsites.net/PAST/pastry.pdf) The paper above, in Section 2.3 contains a specification of the Pastry API and of the API to be implemented by the application.

###  Project 4 Part 1 Twitter Simulator without using Phoenix Web sockets

In this project, you have to implement a Twitter Clone and a client tester/simulator.

As of now, Tweeter does not seem to support a WebSocket API. As part I of this project, you need to build an engine that (in part II) will be paired up with WebSockets to provide full functionality. Specific things you have to do are:

Implement a Twitter like engine with the following functionality:
- <b>Register account</b><br>
- <b>Send tweet</b>. Tweets can have hashtags (e.g. #COP5615isgreat) and mentions (@bestuser)<br>
- <b>Subscribe to user's tweets</b><br>
- <b>Re-tweets</b> (so that your subscribers get an interesting tweet you got by other means)<br>
- Allow querying <b> tweets</b> subscribed to, tweets with specific hashtags, tweets in which the user is mentioned (my mentions)<br>
- If the user is connected, deliver the above types of tweets <b> live</b> (without querying)<br>

Implement a tester/simulator to test the above
-Simulate as many users as you can<br>
-Simulate periods of live connection and disconnection for users<br>
-Simulate a <b>Zipf distribution</b> on the number of subscribers. For accounts with a lot of subscribers, increase the number of tweets. Make some of these messages re-tweets<br>

Other considerations:
-The client part (send/receive tweets) and the engine (distribute tweets) have to be in separate processes. Preferably, you use multiple independent client processes that simulate thousands of clients and a single engine process<br>
-You need to measure various aspects of your simulator and report performance<br>

###  Project 4 Part 1 Twitter Simulator using Phoenix Web sockets

Use Phoenix web framework to implement a WebSocket interface to your part I implementation. That means that, even though the Elixir implementation of your Part I project could use the Erlang messaging to allow client-server implementation, you now need to design and use a proper WebSocket interface. Specifically:

- You need to design a JSON based API that  represents all messages and their replies (including errors)<br>
- You need to re-write your engine using Phoenix to implement the WebSocket interface<br>
- You need to re-write your client to use WebSockets.<br>

Youtube Link for project 4 part 2 implementation - https://www.youtube.com/watch?v=SwTbdf50CGU
