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
// Description: Top of the testbench, actually starts the testbench and instantiates the design module.
// -----------------------------------------------------------------------------

//The top module must be a 'module', not a 'class'
module Parallel_Multiplier_tb;
  import uvm_pkg::*;
  import multiplier_uvm_pkg::*;
  `include "uvm_macros.svh"

  reg clk, rst;
  parameter TB_WIDTH = `TB_WIDTH;

  //Driving the clock signal, which is passed on to all the other components
  always #10 clk = ~clk;
  
  //Main interface to connect the testbench to the design
  mult_if #(TB_WIDTH) _if (clk);
  //Instantiating the Design Under Test (DUT) and connecting the pins with the interface pins
  Multiplier_Wrapper #(.N(TB_WIDTH)) mult ( 
    .clk(clk), 
    .rst(_if.rst), 
    .a_in(_if.a), 
    .b_in(_if.b), 
    .p(_if.p)
  );

  initial begin
    clk <= 0;
    uvm_config_db#(virtual mult_if)::set(null, "uvm_test_top", "mult_vif", _if);
    
    //Start the testbench
    run_test("test");
  end
endmodule