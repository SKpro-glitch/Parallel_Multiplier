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
// Description:  Interface allows verification components to access DUT signals using a virtual interface handle.
// -----------------------------------------------------------------------------

//IF = Interface; mult_if = Multiplier Interface
interface mult_if #(parameter N=32, bits = N-1, prod = 2*N-1) (
	input bit clk
);
  	//Clock is taken as an argument as it will be driven externally
  	//Clock can be declared inside also
  	
  	//Reset can be declared here and toggled using apply_reset function
  	logic rst;
  	
  	//Inputs and outputs must be declared here correctly to match the design pins
  	logic [bits:0] a, b;
	logic [prod:0] p;

	clocking cb @(posedge clk);
	   //Declaring input delay and output delay in the Clocking Block
      default input #0ns output #0ns;
		input p;
		output a, b;
	endclocking
endinterface
