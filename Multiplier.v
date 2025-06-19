`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Soham Kapur 
// 
// Create Date: 12.12.2024 10:04:25
// Module Name: Multiplier
// Project Name: Parallel Multiplier using Carry Save Adder
//////////////////////////////////////////////////////////////////////////////////

//Parallel Multiplier
module Multiplier #(parameter size = 16) 
    //The Size parameter is set for the size of the multiplier and multiplicand.
    //For example, in order to makean 8x8 multiplier, set size as 8.
    (
    input clk, //System clock
    input [bits:0] a, b, //Multiplier and multiplicand
    
    output reg [prod:0] p, v //Output Product and Verification product
    );
    
    //The bits and prod parameters are used to fix the sizes of other registers and loops.
    parameter bits = size-1, prod = 2*bits+1;
    //Bits is for the input values and prod is for the output (product).
    
    wire [bits:0] c [bits:0]; //Stores the intermediate carry values of the carry save adder
    wire [bits-1:0] s [bits:0]; //Stores the intermediate sum values of the carry save adder
    
    //First row of the carry save adder
    Inter_Prod ip0(b[0] ? a : 0, 0, 0, {s[0], p[0]}, c[0]);
    
    //Multiple instances of the Inter_Prod module are generated as per the input size
    genvar i;
    generate
        for(i=1; i<=bits; i=i+1)
            //Carry Save Adder is implemented by giving the carry and sum of one stage to the next stage
            //Instead of giving the carry to the next adder in the same stage
            Inter_Prod ip(b[i] ? a : 0, {1'b0, s[i-1]}, c[i-1], {s[i], p[i]}, c[i]);
    endgenerate
    
    always @ (posedge clk) begin 
        //The last row addition is done for the left half of the product.
        p[prod:prod-bits] = s[bits] + c[bits];
        
        //This is in-built multiplication operation of Verilog.
        //It can be used to verify output after any modifications to the Multiplier.
        v = a * b;
    end
    
endmodule

//Intermediate product calculation
module Inter_Prod(x, y, z, s, c);
    input [bits:0] x, y, z;
    output reg [bits:0] s, c;
    
    //Implementation of Full Adder
    assign s = x ^ y ^ z;
    assign c = (x & y) | (y & z) | (x & z);
        
endmodule
