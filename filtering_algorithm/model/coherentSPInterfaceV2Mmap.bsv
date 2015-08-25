/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: coherentSPInterfaceV2Mmap.bsv
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

import FIFO::*;
import FIFOF::*;
import DefaultValue::*;


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

//`define COH_VERBOSE_MMAP


/*
typedef enum
{
    MY_LOCK = 0
}
LOCK_TYPE_V2
    deriving (Eq, Bits);
*/


interface COHERENTSP_IFC_V2_MMAP#(type t_addr, type t_data);
    method Action setWriteReq(t_addr a, t_data d);
    method Action setReadReq(t_addr a);
    method Action enterCriticalRegion();
    method Action leaveCriticalRegion();
    method Bool enWrite();
    method ActionValue#(t_data) readResp();
endinterface

module [CONNECTED_MODULE] mkCoherentSPInterfaceV2Mmap#( Integer scratchpadID, 
                                                        soft_strings::GLOBAL_STRING_UID initFileName,
                                                        Bool addCaches,
                                                        Bool isMaster)
    // interface:
    (COHERENTSP_IFC_V2_MMAP#(t_addr, t_data))
    provisos (Bits#(t_addr, t_addr_sz),
              Bits#(t_data, t_data_sz));


    // coherent scratchpad
    COH_SCRATCH_CLIENT_CONFIG coh_client_conf = defaultValue;
    coh_client_conf.cacheMode = (addCaches) ? COH_SCRATCH_CACHED : COH_SCRATCH_UNCACHED;

    coh_client_conf.initFilePath = tagged Valid initFileName;

    //DEBUG_FILE debugLogsCohScratch <- mkDebugFile("coherent_scratchpad_"+integerToString(scratchpadID)+".out");
    //MEMORY_WITH_FENCE_IFC#(t_addr, t_data) memory <- mkDebugCoherentScratchpadClient(`VDEV_SCRATCH_COH_MEMPERF_DATA, scratchpadID, coh_client_conf, debugLogsCohScratch);
    MEMORY_WITH_FENCE_IFC#(t_addr, t_data) memory <- mkCoherentScratchpadClient(`VDEV_SCRATCH_COH_MEMPERF_DATA, coh_client_conf);

    // lock service
    //DEBUG_FILE lockDebugLog <- mkDebugFile("lock_service_" + integerToString(scratchpadID) + ".out");
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
    FIFOF#(Bool) lockAcquireFifo <- mkSizedFIFOF(16);
    //FIFOF#(Bool) writeAcceptFifo <- mkSizedFIFOF(16);



    // =======================================================================
    //
    // Rules
    //
    // =======================================================================

    
    rule writeReqAccept ( writeFifo.notEmpty && hasLock ); 

        // this rule fires if the memory performs the write
        writeFifo.deq;

        match {.addr, .data} = writeFifo.first;        
        memory.write(addr, data);
        memory.fence();

        
        if ( !lockReleaseFifo.notEmpty )
        begin
            lockReleaseFifo.enq(True);
        end         

        
        `ifdef COH_VERBOSE
        $display("[%d] mem%d write reponse: lat = %d",unpack(cycle),scratchpadID,unpack(cycle)-unpack(writeStartCycle.first));
        writeStartCycle.deq;
        `endif
        
    endrule 


    
    rule readReqAccept ( readAddrFifo.notEmpty /*&& hasLock */ );
        readAddrFifo.deq;
        memory.readReq(readAddrFifo.first);  
        //memory.readFence();
    endrule 

    rule lockResp ( True );
        let resp <- lock.lockResp();
        if (!lockAcquireFifo.notEmpty )
            lockAcquireFifo.enq(True);  
    endrule

    rule obtainLock ( lockAcquireFifo.notEmpty );
        hasLock <= True;   
        lockAcquireFifo.deq;
        `ifdef COH_VERBOSE
        $display("[%d] mem%d acquire lock",unpack(cycle),scratchpadID);
        `endif
    endrule

    rule releaseLock ( lockReleaseFifo.notEmpty  );
        //if ( !memory.writePending && !memory.readPending )
        //begin
            lockReleaseFifo.deq;
            lock.releaseLock(MY_LOCK);
            hasLock <= False;
            `ifdef COH_VERBOSE
            $display("[%d] mem%d release lock",unpack(cycle),scratchpadID);
            `endif
        //end
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

        
        if ( !hasLock )
        begin
            lock.acquireLockReq(MY_LOCK);
            `ifdef COH_VERBOSE
            $display("[%d] mem%d request lock",unpack(cycle),scratchpadID);
            `endif
        end
        

        `ifdef COH_VERBOSE
        // record cycle in which this rule was triggered
        writeStartCycle.enq(cycle);
        //UInt#(t_addr_sz) addr = unpack(a);
        //UInt#(t_data_sz) data = unpack(d);
        //$display("[%d] mem%d write request: addr = %x, val = %x",unpack(cycle),scratchpadID,addr,data);
        $display("[%d] mem%d write request (hasLock=%d)",unpack(cycle),scratchpadID,(hasLock ? 1 : 0));
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
        //$display("[%d] mem%d read request: addr = %x",unpack(cycle),scratchpadID,addr);
        $display("[%d] mem%d read request (hasLock=%d)",unpack(cycle),scratchpadID,(hasLock ? 1 : 0));
        `endif
    endmethod 

    /*
    method Action enterCriticalRegion();
        if ( !hasLock )
        begin
            lock.acquireLockReq(MY_LOCK);
            `ifdef COH_VERBOSE
            $display("[%d] mem%d request lock",unpack(cycle),scratchpadID);
            `endif
        end
    endmethod


    method Action leaveCriticalRegion();
        if ( hasLock && !lockReleaseFifo.notEmpty )
        begin
            lockReleaseFifo.enq(True);
        end 
    endmethod
    */

    method ActionValue#(t_data) readResp();
    
        let resp <- memory.readRsp();

        `ifdef COH_VERBOSE
        $display("[%d] mem%d read  reponse: lat = %d",unpack(cycle),scratchpadID,unpack(cycle)-unpack(readStartCycle.first));
        readStartCycle.deq;
        `endif

        return resp;

    endmethod   


endmodule

