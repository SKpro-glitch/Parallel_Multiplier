`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Soham Kapur
// 
// Create Date: 12.12.2024 12:08:34
// Module Name: Multiplier_TB
// Project Name: Testbench for Multiplier module 
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Multiplier_TB();
    reg clk = 0;
    
    //Ensure the size here is the same as the size mentioned in the Multiplier module.
    parameter size = 16;
        
    parameter bits = size-1, prod = 2*bits+1;
    
    //Input values A and B
    reg [bits:0] a, b;
    
    //Output values Product and Verification product
    wire [prod:0] product, verification;
    
    //Various inputs of values of A and B to verify the functionality
    initial begin
        #50 a = 10; b = 15;
        #50 a = 25; b = 64;
        #50 a = 84; b = 66;
        #50 a = 125; b = 641;
        #50 a = 43; b = 604;
        #50 a = 11; b = 64;
        #50 a = 25; b = 91;
    end
    
    //Clock signal with time perios 20ns
    always #10 clk = ~clk;
    
    //Multiplier module instantiation
    Multiplier mul(clk, a, b, product, verification);
    
endmodule
