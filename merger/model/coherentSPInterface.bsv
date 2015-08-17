/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: coherentSPInterface.bsv
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

import FIFO::*;
import FIFOF::*;
import DefaultValue::*;

/*
`include "awb/provides/librl_bsv.bsh"

`include "awb/provides/soft_connections.bsh"
`include "awb/provides/soft_services.bsh"
`include "awb/provides/soft_services_lib.bsh"
`include "awb/provides/soft_services_deps.bsh"
`include "awb/rrr/remote_server_stub_MEMPERFRRR.bsh"
`include "awb/provides/mem_services.bsh"
`include "awb/provides/mem_perf_common.bsh"
`include "awb/provides/common_services.bsh"
`include "awb/provides/scratchpad_memory_common.bsh"
`include "awb/provides/coherent_scratchpad_memory_service.bsh"
`include "asim/provides/lock_sync_service.bsh"

`include "awb/dict/VDEV_SCRATCH.bsh"
`include "asim/dict/VDEV_LOCKGROUP.bsh"
*/

`include "awb/provides/librl_bsv.bsh"

`include "awb/provides/soft_connections.bsh"
`include "awb/provides/soft_services.bsh"
`include "awb/provides/soft_services_lib.bsh"
`include "awb/provides/soft_services_deps.bsh"

`include "awb/provides/mem_services.bsh"
`include "awb/provides/common_services.bsh"
`include "awb/provides/scratchpad_memory_common.bsh"
`include "awb/provides/shared_scratchpad_memory_common.bsh"
`include "awb/provides/coherent_scratchpad_memory_service.bsh"
//`include "awb/provides/coherent_scratchpad_performance_common.bsh"

`include "awb/dict/VDEV_SCRATCH.bsh"
//`include "awb/dict/PARAMS_COHERENT_SCRATCHPAD_PERFORMANCE_COMMON.bsh"

`include "asim/dict/VDEV_LOCKGROUP.bsh"
`include "asim/provides/lock_sync_service.bsh"


`define COH_VERBOSE


typedef enum
{
    MY_LOCK = 0
}
LOCK_TYPE
    deriving (Eq, Bits);



interface COHERENTSP_IFC#(type t_addr, type t_data);
    method Action setWriteReq(t_addr a, t_data d);
    method Action setReadReq(t_addr a);
    method Action enterCriticalRegion();
    method Action leaveCriticalRegion();
    method Bool enWrite();
    method ActionValue#(t_data) readResp();
endinterface

module [CONNECTED_MODULE] mkCoherentSPInterface#(Integer scratchpadID,
                                                 Integer logID,  
                                                 Integer cacheEntries, 
                                                 Bool addCaches,
                                                 Bool isMaster)
    // interface:
    (COHERENTSP_IFC#(t_addr, t_data))
    provisos (Bits#(t_addr, t_addr_sz),
              Bits#(t_data, t_data_sz));


    // coherent scratchpad
    COH_SCRATCH_CLIENT_CONFIG coh_client_conf = defaultValue;
    coh_client_conf.cacheMode = (addCaches) ? COH_SCRATCH_CACHED : COH_SCRATCH_UNCACHED;
    coh_client_conf.cacheEntries = cacheEntries;
    coh_client_conf.enableStatistics = tagged Valid ("coh_scratchpad_" + integerToString(logID) + "_stats_");

    //DEBUG_FILE debugLogsCohScratch <- mkDebugFile("coherent_scratchpad_"+integerToString(logID)+".out");
    //MEMORY_WITH_FENCE_IFC#(t_addr, t_data) memory <- mkDebugCoherentScratchpadClient(`VDEV_SCRATCH_COH_MEMPERF_DATA, scratchpadID, coh_client_conf, debugLogsCohScratch);
    MEMORY_WITH_FENCE_IFC#(t_addr, t_data) memory <- mkCoherentScratchpadClient(`VDEV_SCRATCH_COH_MEMPERF_DATA, coh_client_conf);

    // lock service
    //DEBUG_FILE lockDebugLog <- mkDebugFile("lock_service_" + integerToString(logID) + ".out");
    //LOCK_IFC#(LOCK_TYPE) lock <- mkLockNodeDebug(`VDEV_LOCKGROUP_0, isMaster, lockDebugLog);
    LOCK_IFC#(LOCK_TYPE) lock <- mkLockNode(`VDEV_LOCKGROUP_0, isMaster);
    Reg#(Bool) hasLock <- mkReg(False);


    Reg#(Bit#(32)) cycle <- mkReg(0);

    `ifdef COH_VERBOSE
    FIFO#(Bit#(32)) readStartCycle <- mkSizedFIFO(16);
    FIFO#(Bit#(32)) writeStartCycle <- mkSizedFIFO(16);
    `endif

    FIFOF#( Tuple2#(t_addr, t_data) ) writeFifo <- mkSizedBRAMFIFOF(16);
    FIFOF#(t_addr) readAddrFifo <- mkSizedBRAMFIFOF(16);

    FIFOF#(Bool) lockReleaseFifo <- mkSizedFIFOF(16);


    // =======================================================================
    //
    // Rules
    //
    // =======================================================================

    
    rule writeResp ( writeFifo.notEmpty && hasLock ); 
        // this rule fires if the memory performs the write
        writeFifo.deq;

        match {.addr, .data} = writeFifo.first;        
        memory.write(addr, data);
        //memory.writeFence();

        `ifdef COH_VERBOSE
        $display("[%d] mem%d write reponse: lat = %d",unpack(cycle),logID,unpack(cycle)-unpack(writeStartCycle.first));
        writeStartCycle.deq;
        `endif
    endrule 

    rule readReqAccept ( readAddrFifo.notEmpty && hasLock );
        readAddrFifo.deq;
        memory.readReq(readAddrFifo.first);  
    endrule 

    rule obtainLock ( !hasLock );
        let resp <- lock.lockResp();
        hasLock <= True;    
        `ifdef COH_VERBOSE
        $display("[%d] mem%d acquire lock",unpack(cycle),logID);
        `endif
    endrule


    rule releaseLock ( hasLock );
        if ( lockReleaseFifo.notEmpty && !memory.writePending && !memory.readPending )
        begin
            lockReleaseFifo.deq;
            lock.releaseLock(MY_LOCK);
            hasLock <= False;
            `ifdef COH_VERBOSE
            $display("[%d] mem%d release lock",unpack(cycle),logID);
            `endif
        end
    endrule

    `ifdef COH_VERBOSE
    (* fire_when_enabled *)
    rule cycleCount (True);
        cycle <= cycle + 1;
    endrule
    `endif


    // =======================================================================
    //
    // Methods
    //
    // =======================================================================

    method Action setWriteReq(t_addr a, t_data d);

        // remember addr and data
        writeFifo.enq(tuple2(a,d));

        `ifdef COH_VERBOSE
        // record cycle in which this rule was triggered
        writeStartCycle.enq(cycle);
        //UInt#(t_addr_sz) addr = unpack(a);
        //UInt#(t_data_sz) data = unpack(d);
        //$display("[%d] mem%d write request: addr = %x, val = %x",unpack(cycle),logID,addr,data);
        //$display("[%d] mem%d write request",unpack(cycle),logID);
        `endif
    endmethod


    method enWrite = !writeFifo.notEmpty;


    method Action setReadReq(t_addr a);
        // remember addr
        readAddrFifo.enq(a);

        `ifdef COH_VERBOSE
        // record cycle in which this rule was triggered
        readStartCycle.enq(cycle);
        //UInt#(32) addr = unpack(zeroExtend(a));
        //$display("[%d] mem%d read request: addr = %x",unpack(cycle),logID,addr);
        //$display("[%d] mem%d read request",unpack(cycle),logID);
        `endif
    endmethod 

    method Action enterCriticalRegion();
        if ( !hasLock )
            lock.acquireLockReq(MY_LOCK);
    endmethod

    method Action leaveCriticalRegion();
        if ( hasLock && !lockReleaseFifo.notEmpty )
        begin
            lockReleaseFifo.enq(True);
        end 
    endmethod

    method ActionValue#(t_data) readResp();
    
        let resp <- memory.readRsp();

        `ifdef COH_VERBOSE
        $display("[%d] mem%d read  reponse: lat = %d",unpack(cycle),logID,unpack(cycle)-unpack(readStartCycle.first));
        readStartCycle.deq;
        `endif

        return resp;

    endmethod   


endmodule

