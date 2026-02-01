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
// Project Name: Parameterized Parallel Multiplier
// Description: Responsible for instantiating and connecting all testbench components.
// -----------------------------------------------------------------------------

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
