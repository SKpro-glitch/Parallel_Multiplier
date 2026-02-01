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
// Description:  This module is a wrapper for the combinational multiplier. It includes registers, clock and reset signals so that the timing analysis of the combinational module can be done.
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

//The 'N' parameter is set for the size of the multiplier and multiplicand.
//The 'bits' and 'prod' parameters are used to fix the sizes of other registers and loops.
//'bits' is for the input values and 'prod' is for the output (product).

//Parallel Multiplier Wrapper with clock and reset
module Multiplier_Wrapper #(parameter N = 32, bits = N-1, prod = 2*bits+1)(
    input clk, rst, //System clock and reset
    input [bits:0] a_in, b_in, //Multiplier and multiplicand
    
    output reg [prod:0] p //Output Product register
    );
    
    reg [bits:0] a, b; //Registers to store input
    wire [prod:0] product; //Wire to receive output
    
    always @ (posedge clk) begin 
        if(rst) //Resetting the multiplier to zero 
            {a, b} = {{N{1'b0}}, {N{1'b0}}};
        else begin //Assigning the values of wires to the respective registers
            a <= a_in;
            b <= b_in;
            p <= product;
        end
    end
    
    Multiplier #(.N(N)) mul (
        .a(a),
        .b(b),
        .p(product)
    );
endmodule
