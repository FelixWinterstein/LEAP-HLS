This folder contains the Vivado HLS source files and project directory.
Build your Vivado HLS project these source files and call the project *hello_world* (the other scripts will look for this name).
Name the RTL solution *solution1* (default). This makes sure the the generated RTL will be in `./solution1/impl/verilog` (the other scripts will look there for *.v files)
Also, make sure the RTL design has an active low reset in order to be compatible with the wrapper files.
