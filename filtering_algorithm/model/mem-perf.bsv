/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: mem-perf.bsv
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

`include "asim/provides/librl_bsv.bsh"
`include "awb/provides/soft_connections.bsh"
`include "awb/provides/soft_services.bsh"
`include "awb/provides/soft_services_lib.bsh"
`include "awb/provides/soft_services_deps.bsh"
`include "asim/provides/mem_services.bsh"
`include "asim/provides/common_services.bsh"
`include "awb/provides/mem_perf_tester.bsh"
`include "awb/provides/mem_perf_common.bsh"

`include "asim/dict/VDEV_SCRATCH.bsh"

module [CONNECTED_MODULE] mkMemTester ()
    provisos (Bits#(SCRATCHPAD_MEM_VALUE, t_SCRATCHPAD_MEM_VALUE_SZ));


    mkMemTesterCommon(`VDEV_SCRATCH_MEMTEST0,`MEM_TEST_PRIVATE_CACHES != 0);


endmodule
