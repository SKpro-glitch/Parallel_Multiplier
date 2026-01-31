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
// Description: Encapsulate the sequencer, driver and monitor into a single container.
// -----------------------------------------------------------------------------

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
