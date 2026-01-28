# High-Performance Wallace Tree Multiplier IP

**Generic, Parameterized RTL for High-Speed Arithmetic**

## 1. Overview

This IP is a fully combinational, high-speed Wallace Tree Multiplier. Unlike standard multipliers, this core utilizes a logarithmic reduction tree to minimize the critical path, making it ideal for high-frequency DSP applications, Cryptography, and ALU design.

## 2. Key Features

* **Logarithmic Delay:** Path delay is proportional to O(logN), where N is the bit width.

* **Fully Parameterized:** Easily configure bit widths (e.g., 8x8, 16x16, 32x32) via Verilog parameters.

* **Standard Interface:** Simple combinational data_a, data_b inputs and product output.

* **FPGA & ASIC Ready:** Optimized for synthesis across major vendors (Xilinx, Intel, TSMC, GlobalFoundries).

* **Verification:** Includes a self-checking testbench with random stimulus (constrained-random).

## 3. Technical Specifications (Data Sheet)

|   Parameter |   8x8 Bit   |   16x16 Bit   |   32x32 Bit   |
|   :---   |   :---:   |   :---:   |   :---:   |
|   Logic Cells (LUTs)   |	~110   |   ~480   |   ~2100   |
|   Critical Path (ns)   |	2.1 ns   |   4.8 ns   |   7.2 ns   |
|   Max Freq (Target)   |   450 MHz   |   200 MHz |   130 MHz   |
|   Latency   | 0 Cycles   |   0 Cycles   |   0 Cycles   |

**Note:** Performance data based on Xilinx Artix-7 (-2 speed grade) synthesis. ASIC gate counts available upon request.

## 4. Architecture Detail

The design implements a three-stage reduction:

* **Partial Product Generation:** AND-gate matrix.

* **Wallace Reduction Tree:** Multiple levels of Full Adders (3:2 compressors) and Half Adders (2:2 compressors) to reduce partial products to two rows.

* **Final Addition:** A high-speed Carry-Lookahead Adder (CLA) or Vector-Merge Adder to produce the final product.

## 5. View Port Descriptions

|   Port Name   |   Direction   |   Width   |   Description   |
|   :---:   |   :---:   |   :---:   |   :--- |
|   a   |   Input   |   [N-1:0]   |   Multiplicand   |
|   b   |   Input   |	[N-1:0]   |   Multiplier   |
|   p   |	Output   |	[2N-1:0]   |   Final Product (A×B)   |

## 6. Usage Example (Instantiation)

**Verilog:**

   multiplier #(.N(16)) mul (
       .a(input_a),
       .b(input_b),
       .p(result)
   );

## 7. License

Licensed under the Apache License, Version 2.0. You may use this IP in both open-source and commercial projects. See the [Apache 2.0 License](LICENSE) file for details.

**Multiplier Schematic:** 4x4 multiplier
<br>
![image](https://github.com/user-attachments/assets/b64028a8-f875-4ddb-a9af-f5702b26bf18)
<br>

**Adder Row Schematic:** Individual instance of Intermediate Product module
<br>
![image](https://github.com/user-attachments/assets/71dfe993-168c-44d8-8bf0-0bca8460cf78)
