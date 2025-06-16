`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.06.2025 10:52:06
// Design Name: 
// Module Name: Parallel_Multiplier_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import uvm_pkg::*;
`include "uvm_macros.svh";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This is the base transaction object that will be used in the environment to initiate new transactions and capture transactions at DUT interface
class mult_item extends uvm_sequence_item;
  //This is where the input and output ports of the design are declared
  //Clock and Reset can be ignored here
  
  //Input ports are randomized
  rand bit [15:0] a, b;
  
  //Output ports are not randomized
  bit [31:0] p;
  
  // Use the 'field' utility macros to implement standard functions like print, copy, clone, etc
  //Every port must be added to field macro
  `uvm_object_utils_begin(mult_item)
  	`uvm_field_int (a, UVM_DEFAULT)
  	`uvm_field_int (b, UVM_DEFAULT)
  	`uvm_field_int (p, UVM_DEFAULT)
  `uvm_object_utils_end
    
  //The 'new' function must be defined for every class, taking class name as argument
  //It is the eqivalent of a constructor
  function new(string name = "mult_item");
    super.new(name);
  endfunction
endclass

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//The sequencer is a mediator who establishes a connection between sequence and driver
class sequencer extends uvm_sequencer#(mult_item);
  `uvm_component_utils(sequencer)
  
  function new(string name = "sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
        `uvm_info("SQR", $sformatf("Sequencer Build phase done"), UVM_LOW)
  endfunction
endclass
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Interface allows verification components to access DUT signals using a virtual interface handle
//IF = InterFace; mult_if = Multiplier Interface
interface mult_if (input bit clk);
  	//Clock is taken as an argument as it will be driven externally
  	//Clock can be declared inside also
  	
  	//Reset can be declared here and toggled using apply_reset function
  	logic rst;
  	
  	//Inputs and outputs must be declared here correctly to match the design pins
  	logic [15:0] a, b;
	logic [31:0] p;

	clocking cb @(posedge clk);
	   //Declaring input delay and output delay in the CLocking Block
      default input #0ns output #0ns;
		input p;
		output a, b;
	endclocking
endinterface

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Drives the inputs of the DUT
class driver extends uvm_driver #(mult_item);
  `uvm_component_utils(driver) //Call respective utility macros
  function new(string name = "driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  //Virtual interface for Driver to toggle the input pins of the DUT
  virtual mult_if vif;  //vif = virtual interface

  //Build phase of the Driver
  //Build phase instantiates the components that exist inside a component 
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual mult_if)::get(this, "", "mult_vif", vif)) //Instantiating the interface
      `uvm_fatal("DRV", "Could not get vif")
    else
      `uvm_info("DRV", $sformatf("Driver Build phase done"), UVM_LOW)
  endfunction

  //Run phase of the Driver
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      mult_item m_item;
      `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_LOW)
      
      //Acts as semaphore and blocks fetching of next item once item is received
      seq_item_port.get_next_item(m_item);

      //Actual driving of item inputs
      drive_item(m_item);
      
      //Acts as semaphore and blocks the finishing of item until the work is done
      seq_item_port.item_done();
      
      //Adding a delay of 1 clock cycle to synchronise with the Monitor
      repeat(1) @ (posedge vif.clk);
    end
  endtask

  //Actual task to drive the input pins
  virtual task drive_item(mult_item m_item);
    @(vif.cb); 
        //Driven by clock of the Clocking Block
        //Must access input elements from the clocking block
        vif.cb.a <= m_item.a;
        vif.cb.b <= m_item.b;
        //vif.cb.a = m_item.a   ................correct
        //vif.a = m_item.a      ................error
        `uvm_info("DRV", $sformatf("Inputs supplied") ,UVM_LOW);
  endtask
endclass

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Fetches the output of the DUT
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor) //Call respective utility macros
  function new(string name="monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  //Analysis port sends data out from Monitor to be analysed
  uvm_analysis_port  #(mult_item) mon_analysis_port;
  
  //Virtual interface for Monitor to view outputs from the DUT
  virtual mult_if vif;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual mult_if)::get(this, "", "mult_vif", vif)) //Instantiating the interface
      `uvm_fatal("MON", "Could not get vif")
    else
      `uvm_info("MON", $sformatf("Monitor Build phase done"), UVM_LOW)
    mon_analysis_port = new ("mon_analysis_port", this);
  endfunction

  //Run phase performs the actual tasks that the class has been created for
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    // This task monitors the interface for a complete transaction and pushes into the screboard when the transaction is complete
    forever begin
      @(posedge vif.clk); //'Forever' block is triggered at positive edge of clock
      
      //Since no other control signal exists in the DUT, clock is taken as the Control signal
      if (vif.clk) begin
        //Item is instantiated inside the 'forever' block, so an additional 'if' block is needed
        mult_item item = mult_item::type_id::create("item");
        
        //First part of transaction - supplying the input
        item.a = vif.a;
        item.b = vif.b;
        `uvm_info("MON", $sformatf("T=%0t [Monitor]: First part over", $time), UVM_LOW)
        
        //Since output appears in the next clock cycle, a delay of 1 clock cycle is added
        repeat (1) @ (posedge vif.clk);
        
        //Second part of transaction - reading the output
		item.p = vif.p;        
        
        //The item is the written into the Scoreboard for matching
        mon_analysis_port.write(item);
        `uvm_info("MON", $sformatf("T=%0t [Monitor]: Second part over, item:", $time), UVM_LOW)
        
        //Item is printed for reference
        item.print();
      end
    end
  endtask
endclass

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Encapsulate the sequencer, driver and monitor into a single container
class agent extends uvm_agent;
  `uvm_component_utils(agent)
  function new(string name="agent", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  driver 		d0;  // Driver handle
  monitor 		m0;  // Monitor handle
  sequencer     s0;  // Sequencer Handle

  //Building the respective components
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    //Instantiates the Sequencer, Driver and Monitor
    s0 = sequencer::type_id::create("s0", this);
    d0 = driver::type_id::create("d0", this);
    m0 = monitor::type_id::create("m0", this);
    
    `uvm_info("AGE", $sformatf("Agent Build phase done"), UVM_LOW)
  endfunction

  //Connecting Driver to Sequencer
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d0.seq_item_port.connect(s0.seq_item_export);
    `uvm_info("AGE", $sformatf("Agent Connect phase done"), UVM_LOW)
    
    //Monitor is independent of the Driver and Sequencer and is not connected
  endfunction
endclass

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Receives data from Monitor to check correctness
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  //Analysis port receives data from Monitor to analyse
  uvm_analysis_imp #(mult_item, scoreboard) m_analysis_imp;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //Instantiating the final TLM port where the Monitor will send data
    m_analysis_imp = new("m_analysis_imp", this);
    
    `uvm_info("SBD", $sformatf("Scoreboard Build phase done"), UVM_LOW)
  endfunction

  //The conditions to check and validate the results are written in this
  virtual function write(mult_item item);
        if (item.p != (item.a * item.b))
          `uvm_error("SCBD", $sformatf("ERROR! Mismatch a=0x%0h b=0x%0h p=0x%0h Expected: p=0x%0h", item.a, item.b, item.p, (item.a*item.b)))
        else
          `uvm_info("SCBD", $sformatf("PASS! Match a=0x%0h b=0x%0h p=0x%0h Expected: p=0x%0h", item.a, item.b, item.p, ({{16{1'b0}},item.a}*item.b)), UVM_LOW)
  endfunction
endclass

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Responsible for instantiating and connecting all testbench components
class env extends uvm_env;
  `uvm_component_utils(env)
  function new(string name="env", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  agent 		a0; 		// Agent handle
  scoreboard	sb0; 		// Scoreboard handle

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    //Instantiating the Agent and Scoreboard
    a0 = agent::type_id::create("a0", this);
    sb0 = scoreboard::type_id::create("sb0", this);
    `uvm_info("ENV", $sformatf("Environment Build phase done"), UVM_LOW)
  endfunction

  //Here, analysis port from the agent's monitor is connected to the analysis implementation port in scoreboard
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a0.m0.mon_analysis_port.connect(sb0.m_analysis_imp);
    `uvm_info("ENV", $sformatf("Environment Connect phase done"), UVM_LOW)
  endfunction
endclass

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//The main sequence that forms the stimulus and randomizer aspect of the testbench
class gen_item_seq extends uvm_sequence;
  `uvm_object_utils(gen_item_seq)
  function new(string name="gen_item_seq");
    super.new(name);
  endfunction

  //Number of test cases to generate
  int num = 3;
  
  //Uncomment the following 2 lines to randomize the number of tests
  //rand int num;
  //constraint c1 { num inside {[5:10]}; }

  virtual task body();
    for (int i = 0; i < num; i++) begin
    	mult_item m_item = mult_item::type_id::create("m_item");
    	start_item(m_item); 
    	m_item.randomize(); //After this, the Driver will 'get' the item and this function will wait
    	`uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
    	m_item.print();
      	finish_item(m_item); //This will run only after the Driver is 'done' with the item
    end
    `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
  endtask
endclass

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Instantiates an environment, sets up virtual interface handles for sub components and starts a top level sequence
class test extends uvm_test;
  `uvm_component_utils(test)
  function new(string name = "test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  env e0;
  virtual mult_if vif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //Instantiating the Environment
    e0 = env::type_id::create("e0", this);
    if (!uvm_config_db#(virtual mult_if)::get(this, "", "mult_vif", vif))
        `uvm_fatal("TEST", "Did not get vif")
    else
        `uvm_info("TEST", $sformatf("Test Build phase done"), UVM_LOW)

    //Setting the path of the interface to inside the agent
    uvm_config_db#(virtual mult_if)::set(this, "e0.a0.*", "mult_vif", vif);
    //This is done instead of Connection, when connecting to a sub-component instead of an independent component
  endfunction

  virtual task run_phase(uvm_phase phase);
    //Top level sequence is generated
    gen_item_seq seq = gen_item_seq::type_id::create("seq");
    
    //Object is created
    phase.raise_objection(this);
    //apply_reset(); //Optional reset, use if required

    seq.randomize();
    seq.start(e0.a0.s0);
    
    //Since clock period is set to 20ns, a delay of 100ns means 5 clock cycles will be captured
    #100;
    
    //Object is killed
    phase.drop_objection(this);
  endtask

  virtual task apply_reset();
    vif.rst <= 1;
    repeat (1) @ (posedge vif.clk);
    vif.rst <= 0;
    repeat (1) @ (posedge vif.clk);
  endtask
endclass

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Top of testbench, actually starts the testbench and instantiates the design module
//The top module must be a 'module', not a 'class'
module Multiplier_tb;
  reg clk, rst;
  
  //Driving the clock signal, which is passed on to all the other components
  always #10 clk = ~clk;
  
  //Main interface to connect the testbench to the design
  mult_if _if (clk);

  //Instantiating the Design Under Test (DUT) and connecting the pins with the interface pins
  Multiplier mult( .clk(clk), .rst(_if.rst), .a_in(_if.a), .b_in(_if.b), .p(_if.p));

  initial begin
    clk <= 0;
    uvm_config_db#(virtual mult_if)::set(null, "uvm_test_top", "mult_vif", _if);
    
    //Start the testbench
    run_test("test");
  end
endmodule
