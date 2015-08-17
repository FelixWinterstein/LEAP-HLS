//
// Copyright (c) 2014, Intel Corporation
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// Neither the name of the Intel Corporation nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//


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



module [CONNECTED_MODULE] mkMemPerfDriver ()
    provisos (Bits#(SCRATCHPAD_MEM_VALUE, t_SCRATCHPAD_MEM_VALUE_SZ));

    // Output
    STDIO#(Bit#(64))     stdio <- mkStdIO();

    Reg#(Bit#(64))       cycles <- mkReg(0);

    ServerStub_MEMPERFRRR serverStub <- mkServerStub_MEMPERFRRR();

    CONNECTION_CHAIN#(CommandType) cmdOut <- mkConnectionChain("command");
    CONNECTION_ADDR_RING#(Bit#(8), Bit#(1)) finishIn <- mkConnectionAddrRingNode("finish",0);

    Reg#(Bit#(8)) operationsComplete <- mkReg(0);

    let startMsg <- getGlobalStringUID("Test Started %llu\n");
    let endMsg   <-  getGlobalStringUID("Test Ended %llu \n");	    

    rule tickCycles;
        cycles <= cycles + 1;
    endrule

    rule injectOperation;
        let cmd <- serverStub.acceptRequest_RunTest();

        cmdOut.sendToNext(CommandType{workingSet: unpack(cmd.workingSet),
                                      iterations: unpack(cmd.iterations),
                                      command: unpack(cmd.command)});
        stdio.printf(startMsg, list1(cycles));
    endrule

    rule drainOperation;
        let cmd <- cmdOut.recvFromPrev();
    endrule

    rule collectResponses;
        finishIn.deq;
        if(operationsComplete + 1 == finishIn.maxID)
        begin
            serverStub.sendResponse_RunTest(0, 0);
            operationsComplete <= 0;
            stdio.printf(endMsg, list1(cycles));
        end
        else 
        begin
            operationsComplete <= operationsComplete + 1;
        end
    endrule

endmodule
