## 🛠 Simulation Developer Guide

This directory contains a complete UVM 1.2 verification environment for the Wallace Tree Multiplier. The environment is designed to be modular and supports multiple industry-standard simulators via tool-specific Makefiles.

## 🏗 Supported Toolchains

|   Toolchain   |   Makefile    |
|   :---    |   :---:   |
|   AMD Vivado (XSIM)   |   Makefile.vivado |
|   Siemens Questa / ModelSim   |   Makefile.questa |
|   Icarus Verilog  |   Makefile.icarus |

## 🚀 How to Run

Before running, ensure your simulator's binary folder is in your system `PATH`. Open a terminal in the /sim directory and use the -f flag to select your tool's Makefile.

**Using Vivado (XSIM)**

*Run default base test (32-bit):* 
`
make -f Makefile.vivado
`

*Run with custom parameters:* 
`
make -f Makefile.vivado N=16 TEST=multiplier_corner_test
`

## 📂 Verification Hierarchy

To maintain a professional structure, the testbench is split into the following logical components:

* multiplier_uvm_pkg.sv: The primary package file. It handles all include directives for the UVM classes. Compilation order is managed here.

* interface.sv: The SystemVerilog Interface. This is the hardware/software bridge.

* tb_top.sv: The top-level module that instantiates the DUT (Design Under Test) and the Interface, and invokes run_test().

* test.sv: The test library. New scenarios should be added here to keep the environment clean.

## 🧹 Workspace Cleanup

Simulators generate significant metadata (logs, journals, wave databases). To reset your workspace, run:

`
make -f Makefile.<tool> clean
`

## 📝 Developer Notes

* Tab Sensitivity: If editing Makefiles in Notepad, ensure commands are indented with a Tab character, not spaces.

* Adding Files: If you add a new UVM component (e.g., a new monitor), remember to add the `include line in multiplier_uvm_pkg.sv in the correct dependency order.