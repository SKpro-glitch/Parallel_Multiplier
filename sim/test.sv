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
// Description: Instantiates an environment, sets up virtual interface handles for sub components and starts a top level sequence.
// -----------------------------------------------------------------------------

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
    apply_reset(); //Optional reset, use if required

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
