The Filtering Algorithm
=============

This program is an implementation of the Filtering Algorithm [1]. The implementation performs a recursive tree traversal which incorporates complex data-dependent control flow and makes use of pointer-linked data structures and dynamic memory allocation. Details are given in [2]. The Vivado HLS design is intergrated into the LEAP framework, connecting up to 12 memory ports of the HLS core to LEAP scratchpads.

Steps to build it:

1) Create a Vivado HLS project in VivadoHLS/filtering_algorithm/. using the *.cpp and *.h sources in VivadoHLS/.

2) Change into generated_verilog/. and run ./reload_source_files.sh. If you don't have Vivado HLS, ./reload_source_files.sh copies pre-generated verilog files from golden_ref.

3) Change into testbench/. and run 'make' in order to test whether the HLS design can be imported into a BVI wrapper and simulated using iverilog.

4) Run ./build_model.sh to build the LEAP model including the HLS core. 

5) Run ./run_model.sh to setup the LEAP benchmark and start the iverilog simulation of the model.

6) The core output of the Vivado HLS C simulation and LEAP iverilog simulation should be identical.


[1] T. Kanungo, D. Mount, N. Netanyahu, C. Piatko, R. Silverman, and A. Wu, “An Efficient K-Means Clustering Algorithm: Analysis and Implementation,” IEEE Trans. Pattern Anal. Mach. Intell., vol. 24, no. 7, pp. 881–892, Jul. 2002.

[2] F. Winterstein, S. Bayliss, and G. Constantinides, “High-level synthesis of dynamic data structures: A case study using Vivado HLS,” in Proc. Int. Conf. on Field-Programmable Technology, 2013, pp. 362–365.
