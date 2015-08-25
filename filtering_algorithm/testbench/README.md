This folder contains a small testbench wrapping the Vivado HLS core into the BVI and verilog wrappers and running an iverilog simulation.
The Makefile automatically copies the wrapper files in `../wrappers/.` and verilog files in `../generated_verilog/.` into this folder and build a simulation binary.
