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
// Description: The main sequence that forms the stimulus and randomizer aspect of the testbench.
// -----------------------------------------------------------------------------

class gen_item_seq extends uvm_sequence;
  `uvm_object_utils(gen_item_seq)
  function new(string name="gen_item_seq");
    super.new(name);
  endfunction

  //Number of test cases to generate
  int num = 10;
  
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
