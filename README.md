# Parameteirzed Parallel Multiplier

**Generic, Parameterized RTL for High-Speed Arithmetic**

## 1. Overview

This IP is a high-speed Parallel Multiplier. This module utilizes a Carry Save Adder for fast computation of partial prducts, making it ideal for high-frequency DSP applications, Cryptography, and ALU design.

## 2. Key Features

* **Linear Delay:** Path delay of an Array multiplier is proportional to O(N), where N is the bit width.

* **Fully Parameterized:** Easily configure bit widths (e.g., 8x8, 16x16, 32x32) via Verilog parameters.

* **Combinational Choice:** Can be used as a fully combinational module (Multiplier) or as a synchronous module with registers (Multiplier_Wrapper) with no change in functionality.

* **FPGA Ready:** Optimized for synthesis on Xilinx Vivado.

* **Verification:** Includes a self-checking testbench with random stimulus (constrained-random).

## 3. Project Structure

**Root Directory**

* `LICENSE`: Apache 2.0 License.

* `README.md`: This file.

`/rtl` - **Design Under Test**

* `Multiplier.sv`: The main SystemVerilog RTL source for the multiplier. Can be instantiated without the Wrapper for fully combinational use.

* `Multiplier_Wrapper.sv`: The register wrapper for the Multiplier. Without this, static timing analysis cannot be done.

* `Inter_Prod.sv`: Intermediate module to implement the Carry Save Adder. Fully combinational, but cannot be used independently.

`/sim` - **Verification Environment**

* `multiplier_uvm_pkg.sv`: The UVM package (includes all classes).

* `interface.sv`: SystemVerilog interface for DUT connection.

* `tb_top.sv`: Hardware top module for simulation.

* `Makefile.vivado`: Automation for AMD Vivado (XSIM).

* `Makefile.questa`: Automation for Siemens Questa/ModelSim.

* `README_DEV.md`: Developer guide for running simulations.

* Other tb files are also present here. Refer to `README_DEV.md` for more information.

`/syn` - **Synthesis & Benchmarking**

* `syn_vivado.tcl`: Non-project mode Vivado synthesis script.

* `timing.xdc`: Timing constraints.

## 4. Technical Specifications (Data Sheet)

|  Width |  Logic Cells (LUTs)   |  Critical Path (ns)   |  Max Freq (MHz) |
|  :---: |  :---: |  :---: |  :---: |
|  8x8   |  ~70   |  5.362 |  186.498  |
|  16x16 |  ~360  |  10.865   |  92.039   |
|  32x32 |  ~1920 |  18.489   |  54.086   |

Latency with Wrapper = 1 cycle
Latency without Wrapper = 0 cycles (Fully Combinational)

**Note:** Performance data based on *Xilinx Zynq-7000 xc7z012sclg485-2* synthesis.

## 5. Architecture Detail

The design implements the following reductions:

* **Carry Save Adder:** A Carry Save Adder which reduce the size of the critical path to enhance the speed.

* **Intermediate Product:** Each stage of the Carry Save Adder produces an Intermediate Product.

## 6. View Port Descriptions

|   Port Name   |   Direction   |   Width   |   Description   |
|   :---:   |   :---:   |   :---:   |   :--- |
|   a   |   Input   |   [N-1:0]   |   Multiplicand   |
|   b   |   Input   |	[N-1:0]   |   Multiplier   |
|   p   |	Output   |	[2N-1:0]   |   Final Product (A×B)   |

## 7. Quick Start

**Simulate on Linux CLI (Vivado):**
```bash
cd <path to folder>/sim
make -f Makefile.vivado N=32
```
**Simulate on Windows (Vivado)**
1. Ensure **Vivado** is in your System PATH.
2. Install **make** (via [GNUWin32](https://gnuwin32.sourceforge.net/packages/make.htm)).
3. Open Command Prompt in the `sim/` directory.
4. Open and uncomment the respective commands for Windows in the `Makefile.vivado`
5. Run the simulation:
```bash
make -f Makefile.vivado N=32
```
**Synthesize (Vivado):**
```bash
cd <path to folder>/syn
vivado -mode batch -source syn_vivado.tcl -tclargs 32 20.0
```
\* TCL Arguments: Bit Width (N) = 32, Clock Period (PERIOD) = 20.0

*Note:* Simulation and Synthesis scripts are provided only for AMD Vivado. For Intel Quartus or other platforms, the RTL is standard SystemVerilog and can be imported directly into any standard flow.

## 8. Usage Example (Instantiation)

**With Wrapper:**
```bash
   Multiplier_Wrapper #(.N(32)) mul (
        .clk(clk),
        .rst(reset),
        .a_in(input_a),
        .b_in(input_b),
        .p(result)
   );
```

**Without Wrapper:**
```bash
   Multiplier #(.N(32)) mul (
        .a(input_a),
        .b(input_b),
        .p(result)
   );
```

## 9. Sample Schematic

**Multiplier Schematic:** 4x4 multiplier
<br>
![image](https://github.com/user-attachments/assets/b64028a8-f875-4ddb-a9af-f5702b26bf18)
<br>

**Adder Row Schematic:** Individual instance of Intermediate Product module for 4-bit width
<br>
![image](https://github.com/user-attachments/assets/71dfe993-168c-44d8-8bf0-0bca8460cf78)


## 10. License

Licensed under the Apache License, Version 2.0. You may use this IP in both open-source and commercial projects. See the [Apache 2.0 License](LICENSE) file for details.

## 11. Contact

**Email:** sohamkapur134@gmail.com
