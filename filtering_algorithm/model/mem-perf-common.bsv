/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: mem-perf-common.bsv
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
import RegFile::*;

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

`include "awb/dict/PARAMS_MEM_PERF_COMMON.bsh" // Include parameter id.  Headers are generated per awb type


`define N 128
`define K 4
`define P 4
`define S "0.75"

//`define REDUCE_PAR_TO_1
//`define REDUCE_PAR_TO_2
//`define CENTRE_BUFFER_ONCHIP
`define VERBOSE 


typedef enum
{
    STATE_get_command,
    STATE_test_done,
    STATE_start,
    STATE_processing,
    STATE_warmup,
    STATE_finished,
    STATE_exit
}
STATE
    deriving (Bits, Eq);



typedef Bit#(32) CYCLE_COUNTER;
typedef Bit#(`MEM_ADDR) MEM_ADDRESS;
typedef Bit#(512) MEM_DATA0;
typedef Bit#(8) MEM_DATA1;
typedef Bit#(96) MEM_DATA2;
typedef Bit#(64) MEM_DATA3;
typedef Bit#(32) MEM_DATA4;

typedef struct {
    Bit#(64) cntr;
    Bit#(32) n;
    Bit#(8) k;
    Bit#(8)  command;
} CommandType deriving (Bits,Eq);



typedef Bit#(400) TD_in1;
typedef Bit#(512) TD_in1_mmap;
typedef Bit#(32) TD_in2;
typedef Bit#(8) TD_in3;
typedef Bit#(48) TD_in4;
typedef Bit#(48) TD_out1;
typedef Bit#(32) TD_out2;
typedef Bit#(32) TA;



module [CONNECTED_MODULE] mkMemTesterCommon#(Integer scratchpadID, Bool addCaches) (Empty)
    provisos (Bits#(SCRATCHPAD_MEM_VALUE, t_SCRATCHPAD_MEM_VALUE_SZ),
              Bits#(MEM_ADDRESS, t_MEM_ADDR_SZ),
              Alias#(Bit#(TSub#(t_SCRATCHPAD_MEM_VALUE_SZ, 0)), t_MEM_DATA),
              Bits#(t_MEM_DATA, t_MEM_DATA_SZ),
              NumAlias#(TLog#(16), t_SCRATCH_IDX_SZ),
              Alias#(Bit#(t_SCRATCH_IDX_SZ), t_SCRATCH_IDX),
              NumAlias#(TAdd#(0, t_MEM_ADDR_SZ), t_COH_SCRATCH_ADDR_SZ),
              Alias#(Bit#(t_COH_SCRATCH_ADDR_SZ), t_COH_SCRATCH_ADDR));

    //
    // Allocate scratchpads
    //
    

    // ====================================================================
    //
    // Private scratchpads
    //
    // ====================================================================


    let freelistInitFileName <- getGlobalStringUID("freelist_initialization.dat");
    
    PRIVATESP_IFC#(MEM_ADDRESS, MEM_DATA0) scratchpad0_0 <- mkPrivateSPInterface(`VDEV_SCRATCH_MEMTEST0, `CACHE_ENTRIES00, addCaches);
    PRIVATESP_IFC#(MEM_ADDRESS, MEM_DATA1) scratchpad0_1 <- mkPrivateSPInterface(`VDEV_SCRATCH_MEMTEST1, `CACHE_ENTRIES01, addCaches);
    PRIVATESP_IFC#(MEM_ADDRESS, MEM_DATA2) scratchpad0_2 <- mkPrivateSPInterface(`VDEV_SCRATCH_MEMTEST2, `CACHE_ENTRIES02, addCaches);
    PRIVATESP_IFC_MMAP#(MEM_ADDRESS, MEM_DATA4) scratchpad0_4 <- mkPrivateSPInterfaceMmap(`VDEV_SCRATCH_MEMTEST3, `CACHE_ENTRIES04, addCaches,freelistInitFileName);

    `ifndef REDUCE_PAR_TO_1
    PRIVATESP_IFC#(MEM_ADDRESS, MEM_DATA0) scratchpad1_0 <- mkPrivateSPInterface(`VDEV_SCRATCH_MEMTEST4, `CACHE_ENTRIES10, addCaches);
    PRIVATESP_IFC#(MEM_ADDRESS, MEM_DATA1) scratchpad1_1 <- mkPrivateSPInterface(`VDEV_SCRATCH_MEMTEST5, `CACHE_ENTRIES11, addCaches);
    PRIVATESP_IFC#(MEM_ADDRESS, MEM_DATA2) scratchpad1_2 <- mkPrivateSPInterface(`VDEV_SCRATCH_MEMTEST6, `CACHE_ENTRIES12, addCaches);
    PRIVATESP_IFC_MMAP#(MEM_ADDRESS, MEM_DATA4) scratchpad1_4 <- mkPrivateSPInterfaceMmap(`VDEV_SCRATCH_MEMTEST7, `CACHE_ENTRIES14, addCaches,freelistInitFileName);

    `ifndef REDUCE_PAR_TO_2
    PRIVATESP_IFC#(MEM_ADDRESS, MEM_DATA0) scratchpad2_0 <- mkPrivateSPInterface(`VDEV_SCRATCH_MEMTEST8, `CACHE_ENTRIES20, addCaches);
    PRIVATESP_IFC#(MEM_ADDRESS, MEM_DATA1) scratchpad2_1 <- mkPrivateSPInterface(`VDEV_SCRATCH_MEMTEST9, `CACHE_ENTRIES21, addCaches);
    PRIVATESP_IFC#(MEM_ADDRESS, MEM_DATA2) scratchpad2_2 <- mkPrivateSPInterface(`VDEV_SCRATCH_MEMTEST10, `CACHE_ENTRIES22, addCaches);
    PRIVATESP_IFC_MMAP#(MEM_ADDRESS, MEM_DATA4) scratchpad2_4 <- mkPrivateSPInterfaceMmap(`VDEV_SCRATCH_MEMTEST11, `CACHE_ENTRIES24, addCaches,freelistInitFileName);
    
    PRIVATESP_IFC#(MEM_ADDRESS, MEM_DATA0) scratchpad3_0 <- mkPrivateSPInterface(`VDEV_SCRATCH_MEMTEST12, `CACHE_ENTRIES30, addCaches);
    PRIVATESP_IFC#(MEM_ADDRESS, MEM_DATA1) scratchpad3_1 <- mkPrivateSPInterface(`VDEV_SCRATCH_MEMTEST13, `CACHE_ENTRIES31, addCaches);
    PRIVATESP_IFC#(MEM_ADDRESS, MEM_DATA2) scratchpad3_2 <- mkPrivateSPInterface(`VDEV_SCRATCH_MEMTEST14, `CACHE_ENTRIES32, addCaches); 
    PRIVATESP_IFC_MMAP#(MEM_ADDRESS, MEM_DATA4) scratchpad3_4 <- mkPrivateSPInterfaceMmap(`VDEV_SCRATCH_MEMTEST15, `CACHE_ENTRIES34, addCaches,freelistInitFileName);
    `endif
    `endif
    

    // ====================================================================
    //
    // Coherent scratchpads
    //
    // ====================================================================

    `ifndef CENTRE_BUFFER_ONCHIP
    COH_SCRATCH_CONTROLLER_CONFIG coh_controller_conf = defaultValue;
    coh_controller_conf.cacheMode = (addCaches != False) ? COH_SCRATCH_CACHED : COH_SCRATCH_UNCACHED;

    //Reg#(COH_SCRATCH_MEM_ADDRESS) memoryMax <- mkWriteValidatedReg();
    NumTypeParam#(t_COH_SCRATCH_ADDR_SZ) addr_size = ?;
    NumTypeParam#(t_MEM_DATA_SZ) data_size = ?;

    mkCoherentScratchpadController(`VDEV_SCRATCH_COH_MEMPERF_DATA, `VDEV_SCRATCH_COH_MEMPERF_BITS, addr_size, data_size, coh_controller_conf);

    // memory0_3
    COHERENTSP_IFC#(MEM_ADDRESS, MEM_DATA3) scratchpad0_3 <- mkCoherentSPInterface(`VDEV_SCRATCH_MEMTEST16, `CACHE_ENTRIES03, addCaches, True); 

    `ifndef REDUCE_PAR_TO_1
    // memory1_3
    COHERENTSP_IFC#(MEM_ADDRESS, MEM_DATA3) scratchpad1_3 <- mkCoherentSPInterface(`VDEV_SCRATCH_MEMTEST17, `CACHE_ENTRIES13, addCaches, False);

    `ifndef REDUCE_PAR_TO_2
    // memory2_3
    COHERENTSP_IFC#(MEM_ADDRESS, MEM_DATA3) scratchpad2_3 <- mkCoherentSPInterface(`VDEV_SCRATCH_MEMTEST18, `CACHE_ENTRIES23, addCaches, False);

    // memory3_3
    COHERENTSP_IFC#(MEM_ADDRESS, MEM_DATA3) scratchpad3_3 <- mkCoherentSPInterface(`VDEV_SCRATCH_MEMTEST19, `CACHE_ENTRIES33, addCaches, False);
    `endif
    `endif
    `endif


    // Output
    STDIO#(Bit#(64))     stdio <- mkStdIO();

    // Statistics Collection State
    Reg#(CYCLE_COUNTER)  cycle <- mkReg(0);
    Reg#(CYCLE_COUNTER)  startCycle <- mkReg(0);
    Reg#(CYCLE_COUNTER)  endCycle <- mkReg(0);
    Reg#(Bit#(64))       totalLatency <- mkReg(0);


    CONNECTION_CHAIN#(CommandType) commandChain <- mkConnectionChain("command");
    CONNECTION_ADDR_RING#(Bit#(8), Bit#(1))     finishChain  <- mkConnectionAddrRingDynNode("finish");


    Reg#(STATE)          state <- mkReg(STATE_get_command);


    // number of inputs per channel
    Reg#(TD_in2) n <- mkReg(0);
    Reg#(TD_in3) k <- mkReg(0);
    Reg#(TD_in2) nIterations <- mkReg(1);

    // Dynamic parameters    
    PARAMETER_NODE paramNode  <- mkDynamicParameterNode();
    Param#(32) param_nIterations <- mkDynamicParameter(`PARAMS_MEM_PERF_COMMON_CLUSTERING_ITERATIONS,paramNode);

    // Debugging
    DEBUG_SCAN_FIELD_LIST dbg_list = List::nil;
    dbg_list <- addDebugScanField(dbg_list, "state", state);

    let dbgNode <- mkDebugScanNode("Memory performance (mem-perf-common.bsv)", dbg_list);


    // Messages  
    let startMsg <- getGlobalStringUID("Start HLS core\n");
    let doneMsg <- getGlobalStringUID("test done (%d cache entries): cycle = %llu, latency = %llu\n");
    let exitMsg <- getGlobalStringUID("exit\n");
    let clustersOutputMsg <- getGlobalStringUID("cluster output: val = %x, expected = %x, error = %x\n");
    let distortionOutputMsg <- getGlobalStringUID("distortion output: val = %d, error = %d\n");
    
    DEBUG_FILE debugLog <- mkDebugFile("mem_tester.out");


    // File IO    
    
    RegFile#(TA, TD_out1) cntrOut <- mkRegFileLoad("clusters_out_N" + integerToString(`N) + "_K" + integerToString(`K) + "_D3_s" + `S +  ".hex", 0, `K-1);
    RegFile#(TA, TD_out2) distortionOut <- mkRegFileLoad("distortion_out_N" + integerToString(`N) + "_K" + integerToString(`K) + "_D3_s" + `S + ".hex", 0, `K-1);
    

    FIFOF#(TD_in4) cntrInFifo <- mkSizedBRAMFIFOF(256);

    //Reg#(TA) cntrInCounter <- mkReg(0);
    Reg#(TA) treeDataInCounter <- mkReg(0);
    Reg#(TA) treeAddrInCounter <- mkReg(0);
    Reg#(TA) cntrOutCounter <- mkReg(0);
    Reg#(TA) distortionOutCounter <- mkReg(0);

    FIFOF#(TD_out1) clustersOutFifo <- mkSizedBRAMFIFOF(256);
    FIFOF#(TD_out2) distortionOutFifo <- mkSizedBRAMFIFOF(256);

    Reg#(TA) treeDataMmapCounter <- mkReg(0);
    FIFOF#(Bool) treeDataMmapRequestPending <- mkSizedFIFOF(16);
    FIFOF#(TD_in1_mmap) treeDataMmapFifo <- mkSizedBRAMFIFOF(16);

    let initFileName <- getGlobalStringUID("tree_data_N" + integerToString(`N) + "_K" + integerToString(`K) + "_D3_s" + `S + ".dat");
    PRIVATESP_IFC_MMAP#(MEM_ADDRESS, TD_in1_mmap) scratchpadTreeInit <- mkPrivateSPInterfaceMmap(`VDEV_SCRATCH_INIT, 1024, False, initFileName);


    // HLS IP
    MyIP#(TD_in1, TD_in2, TD_in3, TD_in4, TD_out1, TD_out2, MEM_DATA0, MEM_DATA1, MEM_DATA2, MEM_DATA3, MEM_DATA4, TA) filtering_algorithm_top_wrapper <- mkMyIP;


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
            2: begin
                state <= STATE_test_done;
                cntrInFifo.enq(truncate(cmd.cntr));
                //$display("%x",unpack(cmd.cntr));
               end
        endcase
        
        n <= cmd.n; // pick up the number of data points from the host code ( in connected_application-test.cpp )
        k <= cmd.k; // pick up the number of clusters from the host code ( in connected_application-test.cpp )

        nIterations <= param_nIterations; // pick up the number of clustering iterations from a dynamic parameter ( passed as a command line argument)
            
        debugLog.record($format("goGetCommand: command: %s", 
                        ((pack(cmd.command)[1:0] == 1)? "processing" : "finish") ));

        totalLatency <= 0;

    endrule

    
    (* mutually_exclusive = "mmapTreeInitReadReq, mmapTreeInitReadResp" *)
    rule mmapTreeInitReadReq ( state == STATE_processing && !treeDataMmapRequestPending.notEmpty && treeDataMmapFifo.notFull ); 

        TA a = treeDataMmapCounter | (0*(1<<`MEM_TEST_SHIFT));
        scratchpadTreeInit.setReadReq(truncate(a)); 
        treeDataMmapCounter <= treeDataMmapCounter +1;  
        treeDataMmapRequestPending.enq(True);
    endrule 
    
    rule mmapTreeInitReadResp ( state == STATE_processing && treeDataMmapRequestPending.notEmpty ); 
        let resp <- scratchpadTreeInit.readResp(); 
        treeDataMmapRequestPending.deq;
        TD_in1_mmap d = resp;
        treeDataMmapFifo.enq(d);
        `ifdef VERBOSE
        $display("[%d] mmap scratchpad: val = %x", unpack(cycle), unpack(d));
        `endif
    endrule        
    


    (* fire_when_enabled *)
    rule setN ( True );
        filtering_algorithm_top_wrapper.setN(n);
    endrule

    (* fire_when_enabled *)
    rule setK ( True );
        filtering_algorithm_top_wrapper.setK(k);
    endrule

    (* fire_when_enabled *)
    rule setIterations ( True );
        filtering_algorithm_top_wrapper.setL(nIterations);
    endrule


    rule doTestDone (state == STATE_test_done);
        stdio.printf(doneMsg, list3(`CACHE_ENTRIES00, 
                                    zeroExtend(pack(cycle)), 
                                    zeroExtend(pack(endCycle - startCycle)))); 
        finishChain.enq(0,?);
        state <= STATE_get_command;
    endrule

    rule start ( state == STATE_start );

        filtering_algorithm_top_wrapper.start();
        state <=  STATE_processing;

        startCycle <= cycle;

        stdio.printf(startMsg, List::nil);
    endrule

    
    rule enNodeData ( state == STATE_processing && treeDataMmapFifo.notEmpty );
        filtering_algorithm_top_wrapper.en_i_node_data();
    endrule
    

    rule processing (state == STATE_processing);

        filtering_algorithm_top_wrapper.en_root();
        filtering_algorithm_top_wrapper.en_clusters_out();
        filtering_algorithm_top_wrapper.en_distortion_out();

        if ( filtering_algorithm_top_wrapper.ipDone() ) 
        begin
            state <= STATE_test_done;  
            endCycle <= cycle;
        end 
        
    endrule 


    // ====================================================================
    //
    // core FIFOs (input/output).
    //
    // ====================================================================

    
    rule i_node_data (True);
        treeDataInCounter <= treeDataInCounter + 1;
        //filtering_algorithm_top_wrapper.i_node_data( treeDataIn.sub(treeDataInCounter) );

        TD_in1 d = truncate(treeDataMmapFifo.first);
        treeDataMmapFifo.deq;
        filtering_algorithm_top_wrapper.i_node_data( d );

        //`ifdef VERBOSE
        debugLog.record($format("[%d] reading i_node_data from FIFO: (%d) val = %x", unpack(cycle), treeDataInCounter, d));
        $display("[%d] reading i_node_data from FIFO: (%d) val = %x", unpack(cycle), treeDataInCounter, d);
        //`endif        
    endrule 


    rule root (True);
        filtering_algorithm_top_wrapper.root( 1);
        debugLog.record($format("[%d] reading root from FIFO: val = %x",unpack(cycle), 1));
        $display("[%d] reading root from FIFO: val = %x",unpack(cycle), 1);
    endrule 


    rule cntr_pos_init_en (cntrInFifo.notEmpty);
        filtering_algorithm_top_wrapper.en_cntr_pos_init();
    endrule

    (* fire_when_enabled *)
    rule cntr_pos_init (True);

        //cntrInCounter <= cntrInCounter + 1;

        cntrInFifo.deq;

        //filtering_algorithm_top_wrapper.cntr_pos_init( cntrIn.sub(cntrInCounter));
        filtering_algorithm_top_wrapper.cntr_pos_init( cntrInFifo.first);
        //`ifdef VERBOSE
        debugLog.record($format("[%d] reading cntr_pos_init from FIFO: val = %x", unpack(cycle), cntrInFifo.first ));
        $display("[%d] reading cntr_pos_init from FIFO: val = %x", unpack(cycle), cntrInFifo.first);         
        //`endif
    endrule 

    (* fire_when_enabled *)
    rule clusters_out (True);        
        TD_out1 d = filtering_algorithm_top_wrapper.clusters_out();
        clustersOutFifo.enq(d);
    endrule 

    (* fire_when_enabled *)
    rule distortion_out (True);        
        TD_out2 d = filtering_algorithm_top_wrapper.distortion_out();
        distortionOutFifo.enq(d);
    endrule 

    rule clusters_out_stdio (clustersOutFifo.notEmpty);        
        clustersOutFifo.deq;
        TD_out1 d = cntrOut.sub(cntrOutCounter);
        TD_out1 err = clustersOutFifo.first-d;
        stdio.printf(clustersOutputMsg, list3(zeroExtend(clustersOutFifo.first),zeroExtend(d),signExtend(err)));
        cntrOutCounter <= cntrOutCounter + 1;
    endrule 

    rule distortion_out_stdio (distortionOutFifo.notEmpty);        
        distortionOutFifo.deq;
        stdio.printf(distortionOutputMsg, list2(zeroExtend(distortionOutFifo.first),signExtend(distortionOutFifo.first-distortionOut.sub(distortionOutCounter))));
        distortionOutCounter <= distortionOutCounter + 1;
    endrule 


    // ====================================================================
    //
    // memory writes.
    //
    // ====================================================================/

    (* fire_when_enabled *)
    rule hlsBusWriteReq0_0 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr0_0() | (1*(1<<`MEM_TEST_SHIFT));
        MEM_DATA0 d = filtering_algorithm_top_wrapper.writeData0_0();
        scratchpad0_0.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem0_0 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem0_0 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 

    (* fire_when_enabled *)
    rule hlsBusWriteReq0_1 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr0_1() | (2*(1<<`MEM_TEST_SHIFT));
        MEM_DATA1 d = filtering_algorithm_top_wrapper.writeData0_1();
        scratchpad0_1.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem0_1 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem0_1 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 

    (* fire_when_enabled *)
    rule hlsBusWriteReq0_2 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr0_2() | (3*(1<<`MEM_TEST_SHIFT));
        MEM_DATA2 d = filtering_algorithm_top_wrapper.writeData0_2();
        scratchpad0_2.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem0_2 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem0_2 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 

    `ifndef CENTRE_BUFFER_ONCHIP
    (* fire_when_enabled *)
    rule hlsBusWriteReq0_3 ( state == STATE_processing );              
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr0_3() | (4*(1<<`MEM_TEST_SHIFT));
        MEM_DATA3 d = filtering_algorithm_top_wrapper.writeData0_3();
        scratchpad0_3.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem0_3 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem0_3 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 
    `endif

    (* fire_when_enabled *)
    rule hlsBusWriteReq0_4 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr0_4() | (5*(1<<`MEM_TEST_SHIFT));
        MEM_DATA4 d = filtering_algorithm_top_wrapper.writeData0_4();
        scratchpad0_4.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem0_4 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem0_4 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 


    `ifndef REDUCE_PAR_TO_1
    (* fire_when_enabled *)
    rule hlsBusWriteReq1_0 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr1_0() | (6*(1<<`MEM_TEST_SHIFT));
        MEM_DATA0 d = filtering_algorithm_top_wrapper.writeData1_0();
        scratchpad1_0.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem1_0 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem1_0 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 

    (* fire_when_enabled *)
    rule hlsBusWriteReq1_1 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr1_1() | (7*(1<<`MEM_TEST_SHIFT));
        MEM_DATA1 d = filtering_algorithm_top_wrapper.writeData1_1();
        scratchpad1_1.setWriteReq(truncate(a), zeroExtend(d));
        
        `ifdef VERBOSE
        debugLog.record($format("[%d] mem1_1 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem1_1 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 

    (* fire_when_enabled *)
    rule hlsBusWriteReq1_2 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr1_2() | (8*(1<<`MEM_TEST_SHIFT));
        MEM_DATA2 d = filtering_algorithm_top_wrapper.writeData1_2();
        scratchpad1_2.setWriteReq(truncate(a), zeroExtend(d));
       
        `ifdef VERBOSE
        debugLog.record($format("[%d] mem1_2 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem1_2 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 

    `ifndef CENTRE_BUFFER_ONCHIP
    (* fire_when_enabled *)
    rule hlsBusWriteReq1_3 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr1_3() | (9*(1<<`MEM_TEST_SHIFT));
        MEM_DATA3 d = filtering_algorithm_top_wrapper.writeData1_3();
        scratchpad1_3.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem1_3 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem1_3 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 
    `endif

    (* fire_when_enabled *)
    rule hlsBusWriteReq1_4 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr1_4() | (10*(1<<`MEM_TEST_SHIFT));
        MEM_DATA4 d = filtering_algorithm_top_wrapper.writeData1_4();
        scratchpad1_4.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem1_4 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem1_4 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 


    `ifndef REDUCE_PAR_TO_2
    (* fire_when_enabled *)
    rule hlsBusWriteReq2_0 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr2_0() | (11*(1<<`MEM_TEST_SHIFT));
        MEM_DATA0 d = filtering_algorithm_top_wrapper.writeData2_0();
        scratchpad2_0.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem2_0 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem2_0 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 

    (* fire_when_enabled *)
    rule hlsBusWriteReq2_1 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr2_1() | (12*(1<<`MEM_TEST_SHIFT));
        MEM_DATA1 d = filtering_algorithm_top_wrapper.writeData2_1();
        scratchpad2_1.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem2_1 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem2_1 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 

    (* fire_when_enabled *)
    rule hlsBusWriteReq2_2 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr2_2() | (13*(1<<`MEM_TEST_SHIFT));
        MEM_DATA2 d = filtering_algorithm_top_wrapper.writeData2_2();
        scratchpad2_2.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem2_2 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem2_2 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 

    `ifndef CENTRE_BUFFER_ONCHIP
    (* fire_when_enabled *)
    rule hlsBusWriteReq2_3 ( state == STATE_processing  );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr2_3() | (14*(1<<`MEM_TEST_SHIFT));
        MEM_DATA3 d = filtering_algorithm_top_wrapper.writeData2_3();
        scratchpad2_3.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem2_3 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem2_3 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 
    `endif

    (* fire_when_enabled *)
    rule hlsBusWriteReq2_4 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr2_4() | (15*(1<<`MEM_TEST_SHIFT));
        MEM_DATA4 d = filtering_algorithm_top_wrapper.writeData2_4();
        scratchpad2_4.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem2_4 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem2_4 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 


    (* fire_when_enabled *)
    rule hlsBusWriteReq3_0 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr3_0() | (16*(1<<`MEM_TEST_SHIFT));
        MEM_DATA0 d = filtering_algorithm_top_wrapper.writeData3_0();
        scratchpad3_0.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem3_0 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem3_0 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 

    (* fire_when_enabled *)
    rule hlsBusWriteReq3_1 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr3_1() | (17*(1<<`MEM_TEST_SHIFT));
        MEM_DATA1 d = filtering_algorithm_top_wrapper.writeData3_1();
        scratchpad3_1.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem3_1 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem3_1 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 

    (* fire_when_enabled *)
    rule hlsBusWriteReq3_2 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr3_2() | (18*(1<<`MEM_TEST_SHIFT));
        MEM_DATA2 d = filtering_algorithm_top_wrapper.writeData3_2();
        scratchpad3_2.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem3_2 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem3_2 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 

    `ifndef CENTRE_BUFFER_ONCHIP
    (* fire_when_enabled *)
    rule hlsBusWriteReq3_3 ( state == STATE_processing  );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr3_3() | (19*(1<<`MEM_TEST_SHIFT));
        MEM_DATA3 d = filtering_algorithm_top_wrapper.writeData3_3();
        scratchpad3_3.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem3_3 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem3_3 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 
    `endif

    (* fire_when_enabled *)
    rule hlsBusWriteReq3_4 ( state == STATE_processing );               
        // this rule fires if the core wants to write 
        TA a = filtering_algorithm_top_wrapper.writeAddr3_4() | (20*(1<<`MEM_TEST_SHIFT));
        MEM_DATA4 d = filtering_algorithm_top_wrapper.writeData3_4();
        scratchpad3_4.setWriteReq(truncate(a), zeroExtend(d));

        `ifdef VERBOSE
        debugLog.record($format("[%d] mem3_4 write request: addr = %x, val = %x",unpack(cycle),a,d));
        $display("[%d] mem3_4 write request: addr = %x, val = %x",unpack(cycle),a,d);
        `endif
    endrule 

    `endif
    `endif



    rule hlsEnWrite0_0 ( state == STATE_processing && scratchpad0_0.enWrite );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite0_0();          
    endrule

    rule hlsEnWrite0_1 ( state == STATE_processing && scratchpad0_1.enWrite );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite0_1();          
    endrule

    rule hlsEnWrite0_2 ( state == STATE_processing && scratchpad0_2.enWrite  );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite0_2();          
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    rule hlsEnWrite0_3 ( state == STATE_processing && scratchpad0_3.enWrite  );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite0_3();          
    endrule 
    `endif

    rule hlsEnWrite0_4 ( state == STATE_processing && scratchpad0_4.enWrite  );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite0_4();          
    endrule


    `ifndef REDUCE_PAR_TO_1

    rule hlsEnWrite1_0 ( state == STATE_processing && scratchpad1_0.enWrite );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite1_0();          
    endrule

    rule hlsEnWrite1_1 ( state == STATE_processing && scratchpad1_1.enWrite );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite1_1();          
    endrule

    rule hlsEnWrite1_2 ( state == STATE_processing && scratchpad1_2.enWrite  );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite1_2();          
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    rule hlsEnWrite1_3 ( state == STATE_processing && scratchpad1_3.enWrite  );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite1_3();          
    endrule 
    `endif

    rule hlsEnWrite1_4 ( state == STATE_processing && scratchpad1_4.enWrite  );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite1_4();          
    endrule


    `ifndef REDUCE_PAR_TO_2
    rule hlsEnWrite2_0 ( state == STATE_processing && scratchpad2_0.enWrite );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite2_0();          
    endrule

    rule hlsEnWrite2_1 ( state == STATE_processing && scratchpad2_1.enWrite );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite2_1();          
    endrule

    rule hlsEnWrite2_2 ( state == STATE_processing && scratchpad2_2.enWrite  );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite2_2();          
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    rule hlsEnWrite2_3 ( state == STATE_processing && scratchpad2_3.enWrite );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite2_3();          
    endrule 
    `endif

    rule hlsEnWrite2_4 ( state == STATE_processing && scratchpad2_4.enWrite  );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite2_4();          
    endrule


    rule hlsEnWrite3_0 ( state == STATE_processing && scratchpad3_0.enWrite );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite3_0();          
    endrule

    rule hlsEnWrite3_1 ( state == STATE_processing && scratchpad3_1.enWrite );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite3_1();          
    endrule

    rule hlsEnWrite3_2 ( state == STATE_processing && scratchpad3_2.enWrite );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite3_2();          
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    rule hlsEnWrite3_3 ( state == STATE_processing && scratchpad3_3.enWrite  );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite3_3();          
    endrule 
    `endif

    rule hlsEnWrite3_4 ( state == STATE_processing && scratchpad3_4.enWrite  );
        // tell the core that it is allowed to issue a write
        filtering_algorithm_top_wrapper.enWrite3_4();          
    endrule
    `endif
    `endif

    // ====================================================================
    //
    // memory reads.
    //
    // ====================================================================


    (* fire_when_enabled *)
    rule hlsBusReadReq0_0 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest0_0() | (1*(1<<`MEM_TEST_SHIFT));
        scratchpad0_0.setReadReq(truncate(a));
    endrule 

    (* fire_when_enabled *)
    rule hlsBusReadReq0_1 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest0_1() | (2*(1<<`MEM_TEST_SHIFT));
        scratchpad0_1.setReadReq(truncate(a));
    endrule 

    (* fire_when_enabled *)
    rule hlsBusReadReq0_2 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest0_2() | (3*(1<<`MEM_TEST_SHIFT));
        scratchpad0_2.setReadReq(truncate(a));
    endrule 

    `ifndef CENTRE_BUFFER_ONCHIP
    (* fire_when_enabled *)
    rule hlsBusReadReq0_3 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest0_3() | (4*(1<<`MEM_TEST_SHIFT));
        scratchpad0_3.setReadReq(truncate(a));
    endrule  
    `endif

    (* fire_when_enabled *)
    rule hlsBusReadReq0_4 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest0_4() | (5*(1<<`MEM_TEST_SHIFT));
        scratchpad0_4.setReadReq(truncate(a));
    endrule 


    `ifndef REDUCE_PAR_TO_1

    (* fire_when_enabled *)
    rule hlsBusReadReq1_0 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest1_0() | (6*(1<<`MEM_TEST_SHIFT));        
        scratchpad1_0.setReadReq(truncate(a));
    endrule 

    (* fire_when_enabled *)
    rule hlsBusReadReq1_1 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest1_1() | (7*(1<<`MEM_TEST_SHIFT));
        scratchpad1_1.setReadReq(truncate(a));
    endrule 

    (* fire_when_enabled *)
    rule hlsBusReadReq1_2 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest1_2() | (8*(1<<`MEM_TEST_SHIFT));
        scratchpad1_2.setReadReq(truncate(a));
    endrule 

    `ifndef CENTRE_BUFFER_ONCHIP
    (* fire_when_enabled *)
    rule hlsBusReadReq1_3 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest1_3() | (9*(1<<`MEM_TEST_SHIFT));
        scratchpad1_3.setReadReq(truncate(a));
    endrule  
    `endif

    (* fire_when_enabled *)
    rule hlsBusReadReq1_4 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest1_4() | (10*(1<<`MEM_TEST_SHIFT));
        scratchpad1_4.setReadReq(truncate(a));
    endrule 


    `ifndef REDUCE_PAR_TO_2

    (* fire_when_enabled *)
    rule hlsBusReadReq2_0 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest2_0() | (11*(1<<`MEM_TEST_SHIFT));
        scratchpad2_0.setReadReq(truncate(a));
    endrule 

    (* fire_when_enabled *)
    rule hlsBusReadReq2_1 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest2_1() | (12*(1<<`MEM_TEST_SHIFT));
        scratchpad2_1.setReadReq(truncate(a));
    endrule 

    (* fire_when_enabled *)
    rule hlsBusReadReq2_2 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest2_2() | (13*(1<<`MEM_TEST_SHIFT));
        scratchpad2_2.setReadReq(truncate(a));
    endrule 

    `ifndef CENTRE_BUFFER_ONCHIP
    (* fire_when_enabled *)
    rule hlsBusReadReq2_3 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest2_3() | (14*(1<<`MEM_TEST_SHIFT));
        scratchpad2_3.setReadReq(truncate(a));
    endrule  
    `endif

    (* fire_when_enabled *)
    rule hlsBusReadReq2_4 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest2_4() | (15*(1<<`MEM_TEST_SHIFT));
        scratchpad2_4.setReadReq(truncate(a));
    endrule 


    (* fire_when_enabled *)
    rule hlsBusReadReq3_0 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest3_0() | (16*(1<<`MEM_TEST_SHIFT));
        scratchpad3_0.setReadReq(truncate(a));
    endrule 

    (* fire_when_enabled *)
    rule hlsBusReadReq3_1 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest3_1() | (17*(1<<`MEM_TEST_SHIFT));
        scratchpad3_1.setReadReq(truncate(a));
    endrule 

    (* fire_when_enabled *)
    rule hlsBusReadReq3_2 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest3_2() | (18*(1<<`MEM_TEST_SHIFT));
        scratchpad3_2.setReadReq(truncate(a));
    endrule 

    `ifndef CENTRE_BUFFER_ONCHIP
    (* fire_when_enabled *)
    rule hlsBusReadReq3_3 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest3_3() | (19*(1<<`MEM_TEST_SHIFT));
        scratchpad3_3.setReadReq(truncate(a));
    endrule  
    `endif

    (* fire_when_enabled *)
    rule hlsBusReadReq3_4 (state == STATE_processing);    
        TA a = filtering_algorithm_top_wrapper.readRequest3_4() | (20*(1<<`MEM_TEST_SHIFT));
        scratchpad3_4.setReadReq(truncate(a));
    endrule 

    `endif
    `endif



    rule hlsBusReadResp0_0 (state == STATE_processing); 
        let resp <- scratchpad0_0.readResp();   
        MEM_DATA0 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData0_0(d);
        //$display("[%d] mem0_0 read response: val = %x",unpack(cycle),d);
    endrule 

    rule hlsBusReadResp0_1 (state == STATE_processing); 
        let resp <- scratchpad0_1.readResp();   
        MEM_DATA1 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData0_1(d);
    endrule 

    rule hlsBusReadResp0_2 (state == STATE_processing); 
        let resp <- scratchpad0_2.readResp();   
        MEM_DATA2 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData0_2(d);
    endrule 

    `ifndef CENTRE_BUFFER_ONCHIP
    rule hlsBusReadResp0_3 (state == STATE_processing); 
        let resp <- scratchpad0_3.readResp();   
        MEM_DATA3 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData0_3(d);
        //$display("[%d] mem0_3 read response: val = %x",unpack(cycle),d);
    endrule   
    `endif

    rule hlsBusReadResp0_4 (state == STATE_processing); 
        let resp <- scratchpad0_4.readResp();   
        MEM_DATA4 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData0_4(d);
    endrule 


    `ifndef REDUCE_PAR_TO_1

    rule hlsBusReadResp1_0 (state == STATE_processing); 
        let resp <- scratchpad1_0.readResp();   
        MEM_DATA0 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData1_0(d);
        //$display("[%d] mem1_0 read response: val = %x",unpack(cycle),d);
    endrule 

    rule hlsBusReadResp1_1 (state == STATE_processing); 
        let resp <- scratchpad1_1.readResp();   
        MEM_DATA1 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData1_1(d);
    endrule 

    rule hlsBusReadResp1_2 (state == STATE_processing); 
        let resp <- scratchpad1_2.readResp();   
        MEM_DATA2 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData1_2(d);
    endrule 

    `ifndef CENTRE_BUFFER_ONCHIP
    rule hlsBusReadResp1_3 (state == STATE_processing); 
        let resp <- scratchpad1_3.readResp();   
        MEM_DATA3 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData1_3(d);
        //$display("[%d] mem1_3 read response: val = %x",unpack(cycle),d);
    endrule   
    `endif

    rule hlsBusReadResp1_4 (state == STATE_processing); 
        let resp <- scratchpad1_4.readResp();   
        MEM_DATA4 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData1_4(d);
    endrule 



    `ifndef REDUCE_PAR_TO_2

    rule hlsBusReadResp2_0 (state == STATE_processing); 
        let resp <- scratchpad2_0.readResp();   
        MEM_DATA0 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData2_0(d);
        //$display("[%d] mem2_0 read response: val = %x",unpack(cycle),d);
    endrule 

    rule hlsBusReadResp2_1 (state == STATE_processing); 
        let resp <- scratchpad2_1.readResp();   
        MEM_DATA1 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData2_1(d);
    endrule 

    rule hlsBusReadResp2_2 (state == STATE_processing); 
        let resp <- scratchpad2_2.readResp();   
        MEM_DATA2 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData2_2(d);
    endrule 

    `ifndef CENTRE_BUFFER_ONCHIP
    rule hlsBusReadResp2_3 (state == STATE_processing); 
        let resp <- scratchpad2_3.readResp();   
        MEM_DATA3 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData2_3(d);
        //$display("[%d] mem2_3 read response: val = %x",unpack(cycle),d);
    endrule   
    `endif

    rule hlsBusReadResp2_4 (state == STATE_processing); 
        let resp <- scratchpad2_4.readResp();   
        MEM_DATA4 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData2_4(d);
    endrule 


    rule hlsBusReadResp3_0 (state == STATE_processing); 
        let resp <- scratchpad3_0.readResp();   
        MEM_DATA0 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData3_0(d);
        //$display("[%d] mem3_0 read response: val = %x",unpack(cycle),d);
    endrule 

    rule hlsBusReadResp3_1 (state == STATE_processing); 
        let resp <- scratchpad3_1.readResp();   
        MEM_DATA1 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData3_1(d);
    endrule 

    rule hlsBusReadResp3_2 (state == STATE_processing); 
        let resp <- scratchpad3_2.readResp();   
        MEM_DATA2 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData3_2(d);
    endrule 

    `ifndef CENTRE_BUFFER_ONCHIP
    rule hlsBusReadResp3_3 (state == STATE_processing); 
        let resp <- scratchpad3_3.readResp();   
        MEM_DATA3 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData3_3(d);
        //$display("[%d] mem3_3 read response: val = %x",unpack(cycle),d);
    endrule   
    `endif

    rule hlsBusReadResp3_4 (state == STATE_processing); 
        let resp <- scratchpad3_4.readResp();   
        MEM_DATA4 d = truncate(resp);
        filtering_algorithm_top_wrapper.readData3_4(d);
    endrule 
    `endif
    `endif



    // ====================================================================
    //
    // Locks.
    //
    // ====================================================================

    `ifndef CENTRE_BUFFER_ONCHIP
    rule hlsAccessCriticalRegion0 ( True ); 
        Bool r = filtering_algorithm_top_wrapper.accessCriticalRegion0();
        if (r)
            scratchpad0_3.enterCriticalRegion();
        else
            scratchpad0_3.leaveCriticalRegion();
    endrule   

    `ifndef REDUCE_PAR_TO_1
    rule hlsAccessCriticalRegion1 ( True ); 
        Bool r = filtering_algorithm_top_wrapper.accessCriticalRegion1();
        if (r)
            scratchpad1_3.enterCriticalRegion();
        else
            scratchpad1_3.leaveCriticalRegion();
    endrule   

    `ifndef REDUCE_PAR_TO_2
    rule hlsAccessCriticalRegion2 ( True ); 
        Bool r = filtering_algorithm_top_wrapper.accessCriticalRegion2();
        if (r)
            scratchpad2_3.enterCriticalRegion();
        else
            scratchpad2_3.leaveCriticalRegion();
    endrule   

    rule hlsAccessCriticalRegion3 ( True ); 
        Bool r = filtering_algorithm_top_wrapper.accessCriticalRegion3();
        if (r)
            scratchpad3_3.enterCriticalRegion();
        else
            scratchpad3_3.leaveCriticalRegion();
    endrule   
    `endif
    `endif
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
