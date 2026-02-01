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
// Description: Receives data from Monitor to check correctness.
// -----------------------------------------------------------------------------

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
    //A zero-value of size of product is created to implicitly convert to the correct bit width during multiplication
    if (item.p != ((item.p&0) + item.a * item.b))
      `uvm_error("SCBD", $sformatf("ERROR! Mismatch a=0x%0h b=0x%0h p=0x%0h Expected: p=0x%0h", item.a, item.b, item.p, ((item.p&0)+item.a*item.b)))
    else
      `uvm_info("SCBD", $sformatf("PASS! Match a=0x%0h b=0x%0h p=0x%0h Expected: p=0x%0h", item.a, item.b, item.p, ((item.p&0)+item.a*item.b)), UVM_LOW)
  endfunction
endclass
