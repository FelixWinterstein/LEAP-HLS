merger
=============

This program reads four streams of random numbers and outputs a single sorted stream. Internally, it builds and maintains four linked lists. The four lists are built in parallel. The Vivado HLS design is intergrated into the LEAP framework, connecting the four memory ports of the HLS core to LEAP scratchpads.

Steps to build it:

1) Create a Vivado HLS project in VivadoHLS/merger/. using the *.cpp and *.h sources in VivadoHLS/.

2) Change into generated_verilog/. and run ./reload_source_files.sh. If you don't have Vivado HLS, ./reload_source_files.sh copies pre-generated verilog files from golden_ref.

3) Change into testbench/. and run 'make' in order to test whether the HLS design can be imported into a BVI wrapper and simulated using iverilog.

4) Run ./build_model.sh to build the LEAP model including the HLS core. 

5) Run ./run_model.sh to setup the LEAP benchmark and start the iverilog simulation of the model.

6) The core output of the Vivado HLS C simulation and LEAP iverilog simulation should be identical.

