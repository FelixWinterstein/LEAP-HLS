/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: coherentSPInterface.bsv
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
*********************************************************************/


import FIFO::*;
import Vector::*;
import GetPut::*;

`include "asim/provides/librl_bsv.bsh"

`include "asim/provides/soft_connections.bsh"
`include "awb/provides/soft_services.bsh"
`include "awb/provides/soft_services_lib.bsh"
`include "awb/provides/soft_services_deps.bsh"
`include "awb/provides/mem_perf_tester.bsh"
`include "awb/provides/mem_perf_common.bsh"
`include "awb/rrr/remote_server_stub_MEMPERFRRR.bsh"
`include "asim/provides/mem_services.bsh"
`include "asim/provides/common_services.bsh"


module [CONNECTED_MODULE] mkSystem ()
    provisos (Bits#(SCRATCHPAD_MEM_VALUE, t_SCRATCHPAD_MEM_VALUE_SZ));

    let mem_tester <- mkMemTester();
    let mem_perf_driver <- mkMemPerfDriver();
  
endmodule
