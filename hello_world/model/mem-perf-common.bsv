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

import MyIP::*;

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


`define VERBOSE



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

typedef Bit#(`MEM_ADDR) MEM_ADDRESS;
typedef Bit#(`MEM_WIDTH) MEM_DATA;


typedef struct {
    Bit#(32) workingSet;
    Bit#(8) command;
} CommandType deriving (Bits,Eq);



module [CONNECTED_MODULE] mkMemTesterCommon#(Integer scratchpadID, Bool addCaches) (Empty)
    provisos (Bits#(SCRATCHPAD_MEM_VALUE, t_SCRATCHPAD_MEM_VALUE_SZ));

    // ====================================================================
    //
    // HLS core
    //
    // ====================================================================

    MY_IP_WITH_MEM_BUS_IFC#(MEM_DATA,MEM_ADDRESS) hello_world_wrapper <- mkMyIPWithMemBus;
    

    // ====================================================================
    //
    // Private scratchpads
    //
    // ====================================================================

    let initFileName <- getGlobalStringUID("initialization.dat");

    // scratchpad0 (initialized through MMAP interface)
    PRIVATESP_IFC_MMAP#(MEM_ADDRESS, MEM_DATA) memory0 <- mkPrivateSPInterfaceMmap(hello_world_wrapper.busPort0,`VDEV_SCRATCH_MEMTEST0, 0, `CACHE_ENTRIES, addCaches,initFileName);

    // scratchpad1 (not initialized)
    PRIVATESP_IFC#(MEM_ADDRESS, MEM_DATA) memory1 <- mkPrivateSPInterface(hello_world_wrapper.busPort1,`VDEV_SCRATCH_MEMTEST1, 1, `CACHE_ENTRIES, addCaches);


    // ====================================================================
    //
    // STDIO, stats, fsm
    //
    // ====================================================================

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


    `ifdef VERBOSE
    DEBUG_FILE debugLog <- mkDebugFile("mem_tester.out");
    `endif


    // Messages  
    let startMsg <- getGlobalStringUID("Start HLS core\n");
    let doneMsg <- getGlobalStringUID("test done: cycle = %llu, latency = %llu\n");
    let exitMsg <- getGlobalStringUID("exit\n");



    // ====================================================================
    //
    // Operation.
    //
    // ====================================================================

    rule doGetCommand (state == STATE_get_command);
        let cmd <- commandChain.recvFromPrev();
        commandChain.sendToNext(cmd);

        case (pack(cmd.command)[1:0])
            0: state <= STATE_finished;
            1: state <= STATE_start;
        endcase        
            
        `ifdef VERBOSE
        debugLog.record($format("goGetCommand: command: %s", 
                        ((pack(cmd.command)[1:0] == 1)? "processing" : "finish") ));

        if (pack(cmd.command)[1:0] != 0)
        begin
            debugLog.record($format("goGetCommand")); 
        end
        `endif


    endrule


    rule start ( state == STATE_start );

        state <=  STATE_processing;   
        startCycle <= cycle;
        latency <= 0;    
    
        hello_world_wrapper.start();

        stdio.printf(startMsg, List::nil);

    endrule


    rule doTestDone (state == STATE_test_done);
        stdio.printf(doneMsg, list2(zeroExtend(pack(cycle)), 
                                    zeroExtend(pack(endCycle-startCycle))));
        finishChain.enq(0,?);
        state <= STATE_get_command;

    endrule


    rule processing (state == STATE_processing);

        if ( hello_world_wrapper.ipDone() ) 
        begin
            state <= STATE_test_done;  
            endCycle <= cycle;
        end 
        
    endrule 



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
