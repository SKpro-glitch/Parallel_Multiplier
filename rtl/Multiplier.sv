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
// Description:  This module creates a parallel multiplier using the Wallace Tree concept. The input size is set as per the paramter N (N >= 3).
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

//The 'N' parameter is set for the size of the multiplier and multiplicand.
//The 'bits' and 'prod' parameters are used to fix the sizes of other registers and loops.
//'bits' is for the input values and 'prod' is for the output (product).

//Parallel Multiplier
module Multiplier #(parameter N = 32, bits = N-1, prod = 2*bits+1)(
    input [bits:0] a, b, //Multiplier and multiplicand
    
    output [prod:0] p //Output Product
    );
    
    wire [bits:0] c [bits:0]; //Stores the intermediate carry values of the carry save adder
    wire [bits-1:0] s [bits:0]; //Stores the intermediate sum values of the carry save adder
    
    //First row of the carry save adder
    Inter_Prod #(bits) ip0 (
        //Inputs 
        b[0] ? a : 0,
        0,
        0,
        //Outputs
        {s[0], p[0]},
        c[0]
    );
    
    /*
    * Multiple instances of the Inter_Prod module are generated as per the input N. 
    * Each instance is an intermediate row of the carry save adder.
    * Carry Save Adder is implemented by giving the carry and sum of one stage to the next stage.
    */
    genvar i;
    generate
        for(i=1; i<=bits; i=i+1)
            Inter_Prod #(bits) ip (
                //Inputs
                b[i] ? a : 0,
                {1'b0, s[i-1]},
                c[i-1],
                //Outputs
                {s[i], p[i]},
                c[i]
            );
    endgenerate
    
    //The last row addition is done for the MSBs of the product.
    assign p[prod:prod-bits] = s[bits] + c[bits];        
        
endmodule
