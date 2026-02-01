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
// Description:  This is the base transaction object that will be used in the environment to initiate new transactions and capture transactions at DUT interface.
// -----------------------------------------------------------------------------

class mult_item #(parameter N=32, bits = N-1, prod = 2*N-1) extends uvm_sequence_item;
  //This is where the input and output ports of the design are declared
  //Clock and Reset can be ignored here
  
  //Input ports are randomized
  rand bit [bits:0] a, b;
  
  //Output ports are not randomized
  bit [prod:0] p;
  
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
