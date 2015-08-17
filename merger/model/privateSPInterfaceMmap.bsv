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

`include "awb/dict/VDEV_SCRATCH.bsh"

//`define PRIV_VERBOSE_MMAP

interface PRIVATESP_IFC_MMAP#(type t_addr, type t_data);
    method Action setWriteReq(t_addr a, t_data d);
    method Action setReadReq(t_addr a);
    method Bool enWrite();
    method ActionValue#(t_data) readResp();
endinterface

module [CONNECTED_MODULE] mkPrivateSPInterfaceMmap#(Integer scratchpadID, 
                                                    Integer logID,
                                                    Integer cacheEntries, 
                                                    Bool addCaches,
                                                    soft_strings::GLOBAL_STRING_UID initFileName)
    // interface:
    (PRIVATESP_IFC_MMAP#(t_addr, t_data))
    provisos (Bits#(t_addr, t_addr_sz),
              Bits#(t_data, t_data_sz));

    
    // private scratchpad
    SCRATCHPAD_CONFIG sconf = defaultValue;
    sconf.cacheMode = (addCaches ? SCRATCHPAD_CACHED :
                                   SCRATCHPAD_NO_PVT_CACHE
                                   //SCRATCHPAD_UNCACHED 
                                   );
    
    sconf.cacheEntries = cacheEntries;
    sconf.initFilePath = tagged Valid initFileName;
    //sconf.debugLogPath = tagged Valid ("priv_scratchpad_mmap_" + integerToString(logID) + ".out");
    sconf.enableStatistics = tagged Valid ("priv_scratchpad_mmap_" + integerToString(logID) + "_stats_");

    MEMORY_IFC#(t_addr, t_data) memory <- mkScratchpad(scratchpadID, sconf);

    Reg#(Bit#(32)) cycle <- mkReg(0);

    `ifdef PRIV_VERBOSE_MMAP
    FIFO#(Bit#(32)) readStartCycle <- mkSizedFIFO(16);
    FIFO#(Bit#(32)) writeStartCycle <- mkSizedFIFO(16);
    `endif

    FIFOF#( Tuple2#(t_addr, t_data) ) writeFifo <- mkSizedBRAMFIFOF(16);
    FIFOF#(t_addr) readAddrFifo <- mkSizedBRAMFIFOF(16);


    // =======================================================================
    //
    // Rules
    //
    // =======================================================================

    rule writeResp ( writeFifo.notEmpty ); 
        // this rule fires if the memory performs the write
        writeFifo.deq;

        match {.addr, .data} = writeFifo.first;        
        memory.write(addr, data);

        `ifdef PRIV_VERBOSE_MMAP
        $display("[%d] mem%d write reponse: lat = %d",unpack(cycle),logID,unpack(cycle)-unpack(writeStartCycle.first));
        writeStartCycle.deq;
        `endif
    endrule 


    rule readReqAccept ( readAddrFifo.notEmpty);
        readAddrFifo.deq;
        memory.readReq(readAddrFifo.first);  
    endrule 


    `ifdef PRIV_VERBOSE_MMAP
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

        `ifdef PRIV_VERBOSE_MMAP
        // record cycle in which this rule was triggered
        writeStartCycle.enq(cycle);
        `endif
    endmethod

    method enWrite = !writeFifo.notEmpty;


    method Action setReadReq(t_addr a);
        // remember addr
        readAddrFifo.enq(a);

        `ifdef PRIV_VERBOSE_MMAP
        // record cycle in which this rule was triggered
        readStartCycle.enq(cycle);
        `endif
    endmethod 

    method ActionValue#(t_data) readResp();
    
        let resp <- memory.readRsp();

        `ifdef PRIV_VERBOSE_MMAP
        $display("[%d] mem%d read reponse: lat = %d",unpack(cycle),logID,unpack(cycle)-unpack(readStartCycle.first));
        readStartCycle.deq;
        `endif

        return resp;

    endmethod   


endmodule

