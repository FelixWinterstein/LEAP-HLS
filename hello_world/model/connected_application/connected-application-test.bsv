/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: privateSPInterface.bsv
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

`include "awb/provides/soft_connections.bsh"
`include "awb/provides/mem_perf_wrapper.bsh"

// mkConnectedApplication

// Just instantiate the hardware system.

module [CONNECTED_MODULE] mkConnectedApplication
    // interface:
        ();
    
    let sys <- mkSystem();

endmodule
