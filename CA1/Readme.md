# Permutation

CA1 (computer assignment one) <br />
&emsp; Review on logic design:<br />
&emsp; Implement Permutation func:<br />
&emsp;&emsp; 1.phase one: design of controller and datapath on paper<br />
&emsp;&emsp; 2.phase two: implement phase one with verilog<br />

## How to run:
- from `./code`
    *  1.Open this directory in ModelSim and add verilog codes `.v`
    *  2.On Simulate tab click Start Simulation
    *  3.Choose TB in work directory
    *  4.On Simulate tab click Run then run all
    *  5.You can see `outputs` in `./code` directory, only three test cases from 0-2 are available, for more you need to change variable `testCounts` in `./code/TB.v` and add your inputs
- from `./trunk`
    *  1.Choose View tab and click transcript window  
    *  2.Using `cd` command give `./trunk/sim` directory
    *  3.Then run this command in transcript `do sim_top.tcl`
    *  4.Using the tcl code, it runs `./trunk/sim/tb/TB.v` and prepare outputs in `./trunk/sim/file/`
    *  5.Only four test cases from 6-9 are available, for more you need to change variable `testCounts` in `./trunk/sim/tb/TB.v` and add your inputs in `./trunk/sim/file/` directory
