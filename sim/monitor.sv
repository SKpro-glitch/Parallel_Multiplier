// -----------------------------------------------------------------------------
// Copyright 2024 Soham Kapur
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Project Name: N-bit Wallace Tree Multiplier
// Description: Fetches the output of the DUT.
// -----------------------------------------------------------------------------

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
        
        //The item is then written into the Scoreboard for matching
        mon_analysis_port.write(item);
        `uvm_info("MON", $sformatf("T=%0t [Monitor]: Second part over, item:", $time), UVM_LOW)
        
        //Item is printed for reference
        item.print();
      end
    end
  endtask
endclass
