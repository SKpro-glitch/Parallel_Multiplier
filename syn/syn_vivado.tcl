# -----------------------------------------------------------------------------
# Copyright 2024 Soham Kapur
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Project Name: Parameterized Parallel Multiplier
# Description: TCL script for running synthesis in Vivado.
# -----------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Vivado Push-Button Synthesis & Implementation Script (Non-Project Mode)
# ---------------------------------------------------------------------------

set N 32
set PERIOD 20.0

if { $argc > 0 } {
    set N [lindex $argv 0]
}
if { $argc > 1 } {
    set PERIOD [lindex $argv 1]
}

puts "INFO: Synthesizing Wallace Tree with N = $N and PERIOD = ${PERIOD}ns"

# Step 0: Clean up previous runs
#file delete -force reports
#file mkdir reports

# Step 1: Define Target Part (Zynq-7000 xc7z012sclg485-2 as an example)
set_part xc7z012sclg485-2

# Step 2: Read Source Files
# read_verilog -sv automatically handles SystemVerilog files
read_verilog -sv [glob ../rtl/*.sv]
read_xdc timing.xdc

# Step 3: Run Synthesis
# The top module is Multiplier_Wrapper as that the registers are needed for timing analysis.
# -generic N=32: Sets the multiplier bit-width
# -max_dsp 0: Forces Vivado to use LUTs/Logic instead of dedicated DSP slices.
#             This is essential for benchmarking a custom Multipllier RTL.
synth_design -top Multiplier_Wrapper -part xc7z012sclg485-2 -generic N=$N -max_dsp 0

# Step 3b: Override Clock Constraint
# This allows the script to override the value in timing.xdc dynamically
create_clock -period $PERIOD -name clk [get_ports clk]

# Step 4: Run Optimization, Placement and Routing
# This sequence ensures the PPA (Power, Performance, Area) results are accurate
opt_design
place_design
route_design

# Step 5: Generate Professional Reports
# These files provide the data for your main README benchmarks
file delete -force reports/utilization_width_${N}.txt
report_utilization -file reports/utilization_width_${N}.txt
file delete -force reports/timing_width_${N}.txt
report_timing_summary -file reports/timing_width_${N}.txt
file delete -force reports/power_width_${N}.txt
report_power -file reports/power_width_${N}.txt

# Step 6: Finalize
puts "-----------------------------------------------------------------------"
puts "Synthesis and Implementation complete (DSP Slices disabled)."
puts "Please check the 'reports' folder for utilization and timing data."
puts "-----------------------------------------------------------------------"
exit
