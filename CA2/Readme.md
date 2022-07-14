# Secure Hash Algorithm 3 (SHA-3)

CA2 (computer assignment two) <br />
&emsp; Design for the Secure Hash Algorithm 3 (SHA-3):<br />
&emsp; Implement encoder func:<br />
&emsp;&emsp; 1.phase one: design of controller and datapath on paper<br />
&emsp;&emsp; 2.phase two: implement phase one with verilog<br />

## How to run:
- from `./code`
    *  1.Open this directory in ModelSim and add verilog codes `.v`
    *  2.On Simulate tab click Start Simulation
    *  3.Choose TB in work directory
    *  4.On Simulate tab click Run then run all
    *  5.You can see `outputs` in `./code` directory, only three test cases from 0-2 are available, for more you need to change variable `testCounts` in `./code/TB.v` and add your inputs

#### make test in cpp: `./cad_phase2`
&emsp;  To get output of each step and check the difference between them.
