/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: privateSPInterface.bsv
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

import FIFO::*;
import FIFOF::*;
import Vector::*;
import GetPut::*;
import DefaultValue::*;
import LFSR::*;

`include "awb/provides/librl_bsv.bsh"

`include "awb/provides/soft_connections.bsh"
`include "awb/provides/soft_services.bsh"
`include "awb/provides/soft_services_lib.bsh"
`include "awb/provides/soft_services_deps.bsh"
`include "awb/rrr/remote_server_stub_MEMPERFRRR.bsh"
`include "awb/provides/mem_services.bsh"
`include "awb/provides/mem_perf_tester.bsh"
`include "awb/provides/mem_perf_common.bsh"
`include "awb/provides/common_services.bsh"
`include "awb/provides/scratchpad_memory_common.bsh"
`include "awb/provides/coherent_scratchpad_memory_service.bsh"
`include "asim/provides/lock_sync_service.bsh"

`include "awb/dict/VDEV_SCRATCH.bsh"
`include "asim/dict/VDEV_LOCKGROUP.bsh"

`include "awb/dict/PARAMS_MEM_PERF_COMMON.bsh" // Include parameter id.  Headers are generated per awb type


`define SHOW_OUTPUT
`define VERBOSE
//`define REDUCE_PAR_TO_1



typedef enum
{
    STATE_get_command,
    STATE_test_done,
    STATE_writing,
    STATE_start,
    STATE_processing,
    STATE_finished,
    STATE_exit
}
STATE
    deriving (Bits, Eq);


typedef Bit#(40) CYCLE_COUNTER;
typedef Bit#(32) COUNTER_T;
typedef Bit#(`MEM_ADDR) MEM_ADDRESS;
typedef Bit#(`MEM_WIDTH) MEM_DATA0;
typedef Bit#(32) MEM_DATA1;
typedef Bit#(32) IO_DATA;


typedef struct {
    Bit#(32) workingSet;
    Bit#(32) iterations;
    Bit#(8) command;
} CommandType deriving (Bits,Eq);


import MyIP::*;

typedef Bit#(32) TD_io;
typedef Bit#(64) TD_bus;
typedef Bit#(32) TA;

typedef enum { S0, S1, S2, S3} 
ChannelStateType
    deriving (Bits, Eq);

module [CONNECTED_MODULE] mkMemTesterCommon#(Integer scratchpadID, Bool addCaches) (Empty)
    provisos (Bits#(SCRATCHPAD_MEM_VALUE, t_SCRATCHPAD_MEM_VALUE_SZ));

    //
    // Allocate scratchpads
    //
    
    
    // ====================================================================
    //
    // Private scratchpads
    //
    // ====================================================================

    let initFileName <- getGlobalStringUID("freelist_initialization.dat");

    // main scratchpads for data
    PRIVATESP_IFC#(MEM_ADDRESS, MEM_DATA0) memory0 <- mkPrivateSPInterface(`VDEV_SCRATCH_MEMTEST0, 0, `CACHE_ENTRIES, addCaches);

    `ifndef REDUCE_PAR_TO_1 
    PRIVATESP_IFC#(MEM_ADDRESS, MEM_DATA0) memory1 <- mkPrivateSPInterface(`VDEV_SCRATCH_MEMTEST1, 1, `CACHE_ENTRIES, addCaches);
    PRIVATESP_IFC#(MEM_ADDRESS, MEM_DATA0) memory2 <- mkPrivateSPInterface(`VDEV_SCRATCH_MEMTEST2, 2, `CACHE_ENTRIES, addCaches);
    PRIVATESP_IFC#(MEM_ADDRESS, MEM_DATA0) memory3 <- mkPrivateSPInterface(`VDEV_SCRATCH_MEMTEST3, 3, `CACHE_ENTRIES, addCaches);
    `endif

    // scratchpads for freelists
    PRIVATESP_IFC_MMAP#(MEM_ADDRESS, MEM_DATA1) memory4 <- mkPrivateSPInterfaceMmap(`VDEV_SCRATCH_MEMTEST4, 4, `CACHE_ENTRIES, addCaches, initFileName);

    `ifndef REDUCE_PAR_TO_1 
    PRIVATESP_IFC_MMAP#(MEM_ADDRESS, MEM_DATA1) memory5 <- mkPrivateSPInterfaceMmap(`VDEV_SCRATCH_MEMTEST5, 5, `CACHE_ENTRIES, addCaches, initFileName);
    PRIVATESP_IFC_MMAP#(MEM_ADDRESS, MEM_DATA1) memory6 <- mkPrivateSPInterfaceMmap(`VDEV_SCRATCH_MEMTEST6, 6, `CACHE_ENTRIES, addCaches, initFileName);
    PRIVATESP_IFC_MMAP#(MEM_ADDRESS, MEM_DATA1) memory7 <- mkPrivateSPInterfaceMmap(`VDEV_SCRATCH_MEMTEST7, 7, `CACHE_ENTRIES, addCaches, initFileName);
    `endif

    // Output
    STDIO#(Bit#(64))     stdio <- mkStdIO();

    // Statistics Collection State
    Reg#(CYCLE_COUNTER)  cycle <- mkReg(0);
    Reg#(CYCLE_COUNTER)  startCycle <- mkReg(0);
    Reg#(CYCLE_COUNTER)  endCycle <- mkReg(0);
    Reg#(CYCLE_COUNTER)  latency <- mkReg(0);


    CONNECTION_CHAIN#(CommandType) commandChain <- mkConnectionChain("command");
    CONNECTION_ADDR_RING#(Bit#(8), Bit#(1))     finishChain  <- mkConnectionAddrRingDynNode("finish");

    Reg#(STATE)          state <- mkReg(STATE_get_command);   

    // random number generators
    LFSR#(Bit#(16)) lfsr0 <- mkLFSR_16 ;
    LFSR#(Bit#(16)) lfsr1 <- mkLFSR_16 ;
    LFSR#(Bit#(16)) lfsr2 <- mkLFSR_16 ;
    LFSR#(Bit#(16)) lfsr3 <- mkLFSR_16 ;

    Reg#(Bit#(16)) shReg0 <- mkReg('h00);
    Reg#(Bit#(16)) shReg1 <- mkReg('h01);
    Reg#(Bit#(16)) shReg2 <- mkReg('h10);
    Reg#(Bit#(16)) shReg3 <- mkReg('h11);

    // number of inputs per channel
    Reg#(TA) nSamples <- mkReg(64);

    // number of tests to run
    Reg#(TA) nIterations <- mkReg(1);
    Reg#(TA) iterationCounter <- mkReg(0);


    Reg#(COUNTER_T)  outputCounter <- mkReg(0);
    Reg#(COUNTER_T)  outputCounterRaw <- mkReg(0);
    FIFOF#(TD_io) outputFifo <- mkSizedBRAMFIFOF(4096);
    Reg#(TD_io) prevOutput <- mkReg(0);
    Reg#(Bool) mismatch <- mkReg(False);


    `ifdef VERBOSE
    DEBUG_FILE debugLog <- mkDebugFile("mem_tester.out");
    `endif


    // Messages  
    let startMsg <- getGlobalStringUID("Start HLS core (n=%d)\n");
    let doneMsg <- getGlobalStringUID("test done (%llu values): cycle = %llu, latency = %llu\n");
    let exitMsg <- getGlobalStringUID("exit\n");
    let outputMsg <- getGlobalStringUID("core output (%d): val = %d\n");
    let errorMsg <- getGlobalStringUID("core output error (%d): val = %d\n");

    // Dynamic parameters   
    PARAMETER_NODE paramNode  <- mkDynamicParameterNode();
    Param#(32) param_nSamples <- mkDynamicParameter(`PARAMS_MEM_PERF_COMMON_N_SAMPLES,paramNode);


    // HLS IP
    MyIP#(TD_io, TD_bus, TA) merger_top_wrapper <- mkMyIP;


    // ====================================================================
    //
    // Operation.
    //
    // ====================================================================

    rule doGetCommand (state == STATE_get_command);
        let cmd <- commandChain.recvFromPrev();
        commandChain.sendToNext(cmd);

        TA num = param_nSamples; // pick up the number of samples to be sorted from a dynamic parameter ( passed as a command line argument)
        TA it = cmd.iterations; // pick up the number of iterations from the host code ( in connected_application-test.cpp )
        
        case (pack(cmd.command)[1:0])
            0: state <= STATE_finished;
            1: state <= STATE_start;
        endcase        
            
        `ifdef VERBOSE
        debugLog.record($format("goGetCommand: command: %s", 
                        ((pack(cmd.command)[1:0] == 1)? "processing" : "finish") ));

        if (pack(cmd.command)[1:0] != 0)
        begin
            debugLog.record($format("goGetCommand: n = %d",num)); 
        end
        `endif

        nSamples <= num;
        nIterations <= it;

        iterationCounter <= 0;

    endrule


    (* fire_when_enabled *)
    rule setN ( True );
        merger_top_wrapper.setN(nSamples);
    endrule


    rule start ( state == STATE_start );

        state <=  STATE_processing;

        lfsr0.seed(shReg0);
        lfsr1.seed(shReg1);
        lfsr2.seed(shReg2);
        lfsr3.seed(shReg3);

        //inputCounter <= 0;

        startCycle <= cycle;
        latency <= 0;
        outputCounter <= 0;
        outputCounterRaw <= 0;

        outputFifo.clear;

        prevOutput <= 0;
        mismatch <= False;

        merger_top_wrapper.start();

        stdio.printf(startMsg, list1(zeroExtend(pack(nSamples))));

    endrule


    rule doTestDone (state == STATE_test_done);
        stdio.printf(doneMsg, list3(zeroExtend(pack(outputCounterRaw)),
                                    zeroExtend(pack(cycle)), 
                                    zeroExtend(pack(endCycle-startCycle))));
        if (iterationCounter == nIterations) begin
            finishChain.enq(0,?);
            state <= STATE_get_command;
        end else
            state <= STATE_start;
    endrule


    rule processing (state == STATE_processing);

        if ( merger_top_wrapper.ipDone() ) 
        begin
            state <= STATE_test_done;  
            iterationCounter <=  iterationCounter + 1;
            endCycle <= cycle;
        end 
        
    endrule 


    (* fire_when_enabled *)
    rule shiftCycleVal ( True );
        shReg0 <= truncate(cycle);
        shReg1 <= shReg0;
        shReg2 <= shReg1;
        shReg3 <= shReg3;
    endrule


    // ====================================================================
    //
    // core FIFOs (input/output).
    //
    // ====================================================================
    
    (* fire_when_enabled *)
    rule enhlsFifoDataIn0 ( state == STATE_processing /* && inputFifo0.notEmpty */ );
        merger_top_wrapper.enDataIn0();
    endrule

    (* fire_when_enabled *)
    rule enhlsFifoDataIn1 ( state == STATE_processing /* && inputFifo1.notEmpty */ );
        merger_top_wrapper.enDataIn1();
    endrule

    (* fire_when_enabled *)
    rule enhlsFifoDataIn2 ( state == STATE_processing /* && inputFifo2.notEmpty */ );
        merger_top_wrapper.enDataIn2();
    endrule

    (* fire_when_enabled *)
    rule enhlsFifoDataIn3 ( state == STATE_processing /* && inputFifo3.notEmpty */ );
        merger_top_wrapper.enDataIn3();
    endrule
    
    rule hlsFifoDataIn0 ( True );
        merger_top_wrapper.data_in0( zeroExtend(lfsr0.value));
        lfsr0.next;
        //merger_top_wrapper.data_in0( inputFifo0.first );   
        //inputFifo0.deq;
    endrule 

    rule hlsFifoDataIn1 ( True );
        merger_top_wrapper.data_in1( zeroExtend(lfsr1.value));
        lfsr1.next;   
        //merger_top_wrapper.data_in1( inputFifo1.first );   
        //inputFifo1.deq;
    endrule 

    rule hlsFifoDataIn2 ( True );
        merger_top_wrapper.data_in2( zeroExtend(lfsr2.value));
        lfsr2.next;   
        //merger_top_wrapper.data_in2( inputFifo2.first );   
        //inputFifo2.deq;
    endrule 

    rule hlsFifoDataIn3 ( True );
        merger_top_wrapper.data_in3( zeroExtend(lfsr3.value));
        lfsr3.next;   
        //merger_top_wrapper.data_in3( inputFifo3.first );   
        //inputFifo3.deq;
    endrule 


    rule enDataOut (state == STATE_processing && outputFifo.notFull );
        merger_top_wrapper.enDataOut();
    endrule


    (* fire_when_enabled *)
    rule hlsFifoDataOut ( True );        
        TD_io d = merger_top_wrapper.data_out();

        outputFifo.enq(d);
        outputCounterRaw <= outputCounterRaw + 1;
        `ifdef VERBOSE
        $display("[%d] core output: val = %d",unpack(cycle),d);
        `endif
    endrule 

    rule output_stdio (outputFifo.notEmpty );    
        outputCounter <= outputCounter + 1;
        outputFifo.deq;

        mismatch <= (outputFifo.first < prevOutput);

        prevOutput <= outputFifo.first;

        `ifdef SHOW_OUTPUT
        stdio.printf(outputMsg, list2(zeroExtend(outputCounter),zeroExtend(outputFifo.first)));
        `endif
    endrule 


    rule output_mismatch (True );    

        if (mismatch)
            stdio.printf(errorMsg, list2(zeroExtend(outputCounter),zeroExtend(outputFifo.first)));
    endrule 


    // ====================================================================
    //
    // memory writes.
    //
    // ====================================================================/


    (* fire_when_enabled *)
    rule hlsBusWriteReq0 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = merger_top_wrapper.writeAddr0() | (0 * (1<<`MEM_TEST_SHIFT) );
        TD_bus d = merger_top_wrapper.writeData0();
        memory0.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem0 write request: addr = %d, val = %d",unpack(cycle),a,d));
        $display("[%d] mem0 write request: addr = %8d, val = %d",unpack(cycle),a,d);
        `endif
    endrule 

    (* fire_when_enabled *)
    rule hlsBusWriteReq4 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = merger_top_wrapper.writeAddr4() | (4 * (1<<`MEM_TEST_SHIFT) );
        TA d = merger_top_wrapper.writeData4();
        memory4.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem4 write request: addr = %d, val = %d",unpack(cycle),a,d));
        $display("[%d] mem4 write request: addr = %8d, val = %d",unpack(cycle),a,d);
        `endif
    endrule 

    `ifndef REDUCE_PAR_TO_1 

    (* fire_when_enabled *)
    rule hlsBusWriteReq1 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = merger_top_wrapper.writeAddr1() | (1 * (1<<`MEM_TEST_SHIFT) );
        TD_bus d = merger_top_wrapper.writeData1();
        memory1.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem1 write request: addr = %d, val = %d",unpack(cycle),a,d));
        $display("[%d] mem1 write request: addr = %8d, val = %d",unpack(cycle),a,d);
        `endif
    endrule 

    (* fire_when_enabled *)
    rule hlsBusWriteReq2 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = merger_top_wrapper.writeAddr2() | (2 * (1<<`MEM_TEST_SHIFT) );
        TD_bus d = merger_top_wrapper.writeData2();
        memory2.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem2 write request: addr = %d, val = %d",unpack(cycle),a,d));
        $display("[%d] mem2 write request: addr = %8d, val = %d",unpack(cycle),a,d);
        `endif
    endrule 

    (* fire_when_enabled *)
    rule hlsBusWriteReq3 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = merger_top_wrapper.writeAddr3() | (3 * (1<<`MEM_TEST_SHIFT) );
        TD_bus d = merger_top_wrapper.writeData3();
        memory3.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem3 write request: addr = %d, val = %d",unpack(cycle),a,d));
        $display("[%d] mem3 write request: addr = %8d, val = %d",unpack(cycle),a,d);
        `endif
    endrule 

    (* fire_when_enabled *)
    rule hlsBusWriteReq5 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = merger_top_wrapper.writeAddr5() | (5 * (1<<`MEM_TEST_SHIFT) );
        TA d = merger_top_wrapper.writeData5();
        memory5.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem5 write request: addr = %d, val = %d",unpack(cycle),a,d));
        $display("[%d] mem5 write request: addr = %8d, val = %d",unpack(cycle),a,d);
        `endif
    endrule 

    (* fire_when_enabled *)
    rule hlsBusWriteReq6 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = merger_top_wrapper.writeAddr6() | (6 * (1<<`MEM_TEST_SHIFT) );
        TA d = merger_top_wrapper.writeData6();
        memory6.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem6 write request: addr = %d, val = %d",unpack(cycle),a,d));
        $display("[%d] mem6 write request: addr = %8d, val = %d",unpack(cycle),a,d);
        `endif
    endrule 

    (* fire_when_enabled *)
    rule hlsBusWriteReq7 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = merger_top_wrapper.writeAddr7() | (7 * (1<<`MEM_TEST_SHIFT) );
        TA d = merger_top_wrapper.writeData7();
        memory7.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem7 write request: addr = %d, val = %d",unpack(cycle),a,d));
        $display("[%d] mem7 write request: addr = %8d, val = %d",unpack(cycle),a,d);
        `endif
    endrule 

    `endif


    rule hlsEnWrite0 ( state == STATE_processing && memory0.enWrite );
        // tell the core that it is allowed to issue a write
        merger_top_wrapper.enWrite0();          
    endrule

    rule hlsEnWrite4 ( state == STATE_processing && memory4.enWrite );
        // tell the core that it is allowed to issue a write
        merger_top_wrapper.enWrite4();          
    endrule

    `ifndef REDUCE_PAR_TO_1 

    rule hlsEnWrite1 ( state == STATE_processing && memory1.enWrite );
        // tell the core that it is allowed to issue a write
        merger_top_wrapper.enWrite1();          
    endrule

    rule hlsEnWrite2 ( state == STATE_processing && memory2.enWrite );
        // tell the core that it is allowed to issue a write
        merger_top_wrapper.enWrite2();          
    endrule

    rule hlsEnWrite3 ( state == STATE_processing && memory3.enWrite );
        // tell the core that it is allowed to issue a write
        merger_top_wrapper.enWrite3();
    endrule

    rule hlsEnWrite5 ( state == STATE_processing && memory5.enWrite );
        // tell the core that it is allowed to issue a write
        merger_top_wrapper.enWrite5();
    endrule

    rule hlsEnWrite6 ( state == STATE_processing && memory6.enWrite );
        // tell the core that it is allowed to issue a write
        merger_top_wrapper.enWrite6();
    endrule

    rule hlsEnWrite7 ( state == STATE_processing && memory7.enWrite );
        // tell the core that it is allowed to issue a write
        merger_top_wrapper.enWrite7();
    endrule

    `endif

    // ====================================================================
    //
    // memory reads.
    //
    // ====================================================================


    (* fire_when_enabled *)
    rule hlsBusReadReq0 (state == STATE_processing);    
        TA a = merger_top_wrapper.readRequest0() | (0 * (1<<`MEM_TEST_SHIFT) );
        memory0.setReadReq(truncate(a));
    endrule 

    (* fire_when_enabled *)
    rule hlsBusReadReq4 (state == STATE_processing);    
        TA a = merger_top_wrapper.readRequest4() | (4 * (1<<`MEM_TEST_SHIFT) );
        memory4.setReadReq(truncate(a));
    endrule 

    `ifndef REDUCE_PAR_TO_1 

    (* fire_when_enabled *)
    rule hlsBusReadReq1 (state == STATE_processing);    
        TA a = merger_top_wrapper.readRequest1() | (1 * (1<<`MEM_TEST_SHIFT) );
        memory1.setReadReq(truncate(a));
    endrule 

    (* fire_when_enabled *)
    rule hlsBusReadReq2 (state == STATE_processing);    
        TA a = merger_top_wrapper.readRequest2() | (2 * (1<<`MEM_TEST_SHIFT) );
        memory2.setReadReq(truncate(a));
    endrule 

    (* fire_when_enabled *)
    rule hlsBusReadReq3 (state == STATE_processing);    
        TA a = merger_top_wrapper.readRequest3() | (3 * (1<<`MEM_TEST_SHIFT) );
        memory3.setReadReq(truncate(a));
    endrule 

    (* fire_when_enabled *)
    rule hlsBusReadReq5 (state == STATE_processing);    
        TA a = merger_top_wrapper.readRequest5() | (5 * (1<<`MEM_TEST_SHIFT) );
        memory5.setReadReq(truncate(pack(a)));
    endrule 

    (* fire_when_enabled *)
    rule hlsBusReadReq6 (state == STATE_processing);    
        TA a = merger_top_wrapper.readRequest6() | (6 * (1<<`MEM_TEST_SHIFT) );
        memory6.setReadReq(truncate(a));
    endrule 

    (* fire_when_enabled *)
    rule hlsBusReadReq7 (state == STATE_processing);    
        TA a = merger_top_wrapper.readRequest7() | (7 * (1<<`MEM_TEST_SHIFT) );
        memory7.setReadReq(truncate(a));
    endrule 

    `endif


    rule hlsBusReadResp0 (state == STATE_processing); 
        let resp <- memory0.readResp();   
        TD_bus d = truncate(resp);
        merger_top_wrapper.readData0(d);
    endrule 

    rule hlsBusReadResp4 (state == STATE_processing); 
        let resp <- memory4.readResp();   
        TA d = truncate(resp);
        merger_top_wrapper.readData4(d);
    endrule 

    `ifndef REDUCE_PAR_TO_1 

    rule hlsBusReadResp1 (state == STATE_processing); 
        let resp <- memory1.readResp();   
        TD_bus d = truncate(resp);
        merger_top_wrapper.readData1(d);
    endrule 

    rule hlsBusReadResp2 (state == STATE_processing); 
        let resp <- memory2.readResp();   
        TD_bus d = truncate(resp);
        merger_top_wrapper.readData2(d);
    endrule 

    rule hlsBusReadResp3 (state == STATE_processing); 
        let resp <- memory3.readResp();   
        TD_bus d = truncate(resp);
        merger_top_wrapper.readData3(d);
    endrule 

    rule hlsBusReadResp5 (state == STATE_processing); 
        let resp <- memory5.readResp();   
        TA d = truncate(resp);
        merger_top_wrapper.readData5(d);
    endrule 

    rule hlsBusReadResp6 (state == STATE_processing); 
        let resp <- memory6.readResp();   
        TA d = truncate(resp);
        merger_top_wrapper.readData6(d);
    endrule 

    rule hlsBusReadResp7 (state == STATE_processing); 
        let resp <- memory7.readResp();   
        TA d = truncate(resp);
        merger_top_wrapper.readData7(d);
    endrule 

    `endif

    // ====================================================================
    //
    // Stats.
    //
    // ====================================================================

    (* fire_when_enabled *)
    rule cycleCount (True);
        cycle <= cycle + 1;
    endrule


    // ====================================================================
    //
    // End of program.
    //
    // ====================================================================

    rule sendDone (state == STATE_finished);
        stdio.printf(exitMsg, List::nil);
        state <= STATE_exit;
    endrule

    rule finished (state == STATE_exit);
        noAction;
        //$finish(1);  
    endrule

endmodule
