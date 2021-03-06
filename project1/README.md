# DOSFall2017
## Project 1 Distributed Bit Coin Miner on Elixir
## Implementation
Group Members: <br/>
1. Shubham Agiwal, UFID: 20562669, shubhamagiwal92@ufl.edu <br/>
2. Karan Sharma, UFID 00174451, karansharma@ufl.edu<br/>
-----------------------------------------------------------------------------------------------------------------------------
## Source file location: <br/> 
project1/lib/project1.ex <br/>

-----------------------------------------------------------------------------------------------------------------------------
## Usage
1.  cd to the project1 folder<br/>
2.  Run mix deps.get <br/>
3.  Run mix escript.build <br/>
4.  Ignore the warnings <br/>
5.  Run ./project1 [k | ip_addr] <br/>
----------------------------------------------------------------------------------------------------------------------------
## Implementation Details
For local implementation follow the Usage guidelines above. <br/>
  ./project1 [k | ip_addr] <br/>
  where k=number of leading zeros for the generated bitcoins required<br/>
        ip_addr= IP Address of the server you want to connect to, in this case the local machine acts aa a miner<br/>
### Work Unit Generation
The string generation in our project for bitcoin mining is an iterative approach where we are genrating a workload of 10,000,000 for each process on the machine. Each process will be provided a start number and workload. The process will then mine for the bitcoin between start number and the workload.

### Server work unit metrics
Here we have defined the number of processes to run as = No.of Cores * 4. This ensures that all the cores are used efficiently to mine bitcoins in a faster manner.
### Miner work unit metrics
Here we have defined the number of processes to run as one when the miner connect to the server. We can extend it to have multiple process on the same miner.

### Client Server Architecture
When we run the code as server we run No.of Cores * 4 on the server to ensure that all the cores are utilised completely to mine bitcoins based on the k values passed. Since we have a fixed workload, when a process in the server completes a given workload, it send a requests to server for the new workload. The server then allocates the new workload for this process. This mechanism repeats itself until the user manually kills the server.

When the client joins the server,it requests the server for the workload and the k value. Based on the workload and the k value, it allocates a single process for the bitcoin mining in the client.

When the server or client get a bitcoin, they send the value of the random string and its hash value back to the server to be printed on the console.

Note: When the server shuts down the client will not shutdown but it will throw a bad arg exception.

----------------------------------------------------------------------------------------------------------------------------

## Assignment Details

### Work Unit 
 The work unit we defined for each actor was 10,000,000. We specifically chose this work unit because 
 
 a) This will avoid the possibilty of repeated generation of the same string across the workers.
 b) Since different workers get different workloads-> this approach can be horizontally scalabale
 c) Better range for doing the bitcoining operation for a given process/


### Result for ./project1 4
The Result for running the ./project1 4 program on an 8-core intel core i7 is as follows
#### Input  
./project1 4 <br/>
#### Output
:"server@128.227.248.168"
#PID<0.78.0>
4
shubhamagiwal92;14000807	0000FB005030E761A5DBABED7D4C458C55B0D9AEFF82D1A7C8EF130F7029DDFE
shubhamagiwal92;24018048	0000A468A0D36E0F0253374F5BAEFFE928697029B03EED1190505504E59C2EFC
shubhamagiwal92;30020043	0000F74E050A41C671844D1EA6DB19CD0E6E032653EB7F4ABE7D7B5CF8217204
shubhamagiwal92;28029250	000054A3B7F65FD91E687F6A3B259606FB32B3F961D78F4B36C744FEF7C469BB
shubhamagiwal92;32003842	0000E12C581AF4C0FCDE11193882E888048C4E555B40EAB997E8F4024BC6F92E
shubhamagiwal92;24039788	00007CC8AACB1D48D3D738A69CA568113001C7EE14E2E400B9758B54DF2CDC4A
shubhamagiwal92;30044773	00009C5919800FEBFA9176A6E587A115AAFDD1268AC7A224CA06B9CFBC3BCC2E
shubhamagiwal92;13008180	0000FC0F6756A3EB1FF057C24716CBF937FF20A0683F7C78BD04431C661A9914
shubhamagiwal92;23012457	00005C53E1C5E48AFC052D0083F9DD03238A2962754A640338469AA4477B62DD
shubhamagiwal92;30046207	000068A31FB6101AF5401EA238FBEA952FD9EA64E919B2913B4A8988EB6694AE
shubhamagiwal92;4069171	0000D9A69A27EC0AD036BF9FF1174678122201B6AC6D06D1C5E32EBE5D744C37
shubhamagiwal92;25056075	0000CE5CE6BF930E203F8E8AD7E84E564178F86F0D7B7FE51608BEBCD8A813F7
shubhamagiwal92;29066113	0000286EA5B5F285C28866B90A9573DA051825FB106806A64424F629162CE1DF
shubhamagiwal92;21139968	0000F45EAD310EA2A2AB564ED7BCCB37252E85F0ED060F9741604A3B5407F7CE
shubhamagiwal92;16068160	0000A71F61B7C5CA51040713D1E72EDD4469CA7F9C86DFD246CC453D548602F9
shubhamagiwal92;31078051	00000731F348B43ACF838A1D054CC918A01FE99CE5D1C5D4701E040494419E32
shubhamagiwal92;3091010	0000AC95DFA7D66B671920EC5154D4A7EBB66A73D75806B822DC94DD0D83D2A5
shubhamagiwal92;4084662	000055CE9AC2975EF2815692BBEE195C99F5B5DE15C8502B6246F24B6F81CF5E
shubhamagiwal92;15238981	000021AF1814B4AAE82E177875604FCDE0467CF009C23E082253B92F13105265
shubhamagiwal92;25069739	0000E8BDC2CEABAE843568D45249B5032F00F8548688E7F097767E0E919663C4
shubhamagiwal92;15241439	000073FDB8757E3FF868BA9BA9C8E1487804BCFE70277F00FD7CD68B8CD80435
shubhamagiwal92;11074754	0000C8B078B46A9B71AB529D8A246C5A140A9BC00F532B2CF602758879C43050
shubhamagiwal92;4090639	000077A44C487D14B583CD3FDC54BAA0BC801F3E6357673688232137D04A5A93
shubhamagiwal92;28184332	00009A80ED448E6EFD2D3646C807AAB2116A21B3B9A77B301FC45EECA3B5AA01
shubhamagiwal92;21189905	0000454A8C9FED8F7A2BE8D1D9F19D50770C45D8534EF2A2965D18A8E9F7D66E
shubhamagiwal92;31101019	000094A29C2A8BB79083FA7B12670B1A447C033CAC1F4F2916652F38945D1F78
^C

real	0m5.175s<br/>
user	0m38.248s<br/>
sys	  0m0.292s<br/>

### CPU Utilisation for ./project 5
Result of running the program on an 8-core intel core i7 for ./project1 5 is 

#### Input  
time ./project1 5 <br/>
#### Output
:"server@128.227.248.168"
#PID<0.78.0>
5
shubhamagiwal92;9025524	  0000033C84CBE9BD7032325180BCB97BE5B2CA68A03CEE46D143E668F22D9D82
shubhamagiwal92;31078051	00000731F348B43ACF838A1D054CC918A01FE99CE5D1C5D4701E040494419E32
shubhamagiwal92;8127315	  000003D708092B3A10F7EA101C8AA000B7AFBF8AE331B2C2388BC56BA16D6B50
shubhamagiwal92;20129367	00000371396E0F87BC1E91BA42E52D9E9292B8E8DC2DAE57455703D12C4E4836
shubhamagiwal92;23126122	00000889DD2D9A2C4CC468E6638D6A282A826720150AC7AC48DE37BD176B1DD1
shubhamagiwal92;22254971	00000F207C4BE5BC80DC64B53AFF9981CEB6646A316F3CD33D9968F7C2A07C86
shubhamagiwal92;17212062	000006EDA6E1A4D2F77B3B4F9E81CABA9E55FE95F4ED6317515D313E77849BD0
shubhamagiwal92;5307344	  00000BBDFA77C19A12E698CC1A71E6A54B00FD3D2CBFBCECE433344EAAE5AD69
shubhamagiwal92;8283905	  00000E7BA6AC1A45609A14A27FA87E22F6F202BCFBBA287658B3B7353556334C
shubhamagiwal92;31269783	000005624D322F4C86EAA6B1E1B9B758F985F3C8DF7D775B527E3F68A1CEB48E
^C

real	0m10.157s<br/>
user	1m18.576s<br/>
sys	  0m0.412s<br/>

Total CPU Time  = 1m18.576s= 78.576s<br/>
Total Real Time = 0m10.157s= 10.157s<br/>
The ratio of CPU to Real Time = 7.73<br/>

### The coin with the most number of leading 0s that we able to mine
#### Input
/project1 7 <br/>
#### Output
:"server@128.227.248.169"
shubhamagiwal92;291328354	0000000AA373B38A15BBB3605C0C2757A07E9339E4D12F095747E39EA56CCC90
^C

Number of Zeros : 7

#### Largest number of working machines we tested our code on 

We connected four i-7 octa core machines locally where 1 was the server with all cores utilized at 100% and 3 miners with one process running on them and utilising only one cpu 100% as we are running only one process on the client.

