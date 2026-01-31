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
// Description: Drives the inputs of the DUT.
// -----------------------------------------------------------------------------

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
