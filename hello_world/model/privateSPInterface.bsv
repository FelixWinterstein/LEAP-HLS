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
import MyIP::*;


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

`define PRIV_VERBOSE

interface PRIVATESP_IFC#(type t_addr, type t_data);
endinterface

module [CONNECTED_MODULE] mkPrivateSPInterface#(HLS_AP_BUS_IFC#(Bit#(t_data_sz),Bit#(t_addr_sz)) bus,
                                                Integer scratchpadID,
                                                Integer logID, 
                                                Integer cacheEntries,
                                                Bool addCaches)
    // interface:
    (PRIVATESP_IFC#(Bit#(t_addr_sz), Bit#(t_data_sz)));

    
    // private scratchpad config
    SCRATCHPAD_CONFIG sconf = defaultValue;
    sconf.cacheMode = (addCaches ? SCRATCHPAD_CACHED :
                                   SCRATCHPAD_NO_PVT_CACHE
                                   //SCRATCHPAD_UNCACHED 
                                   );
    sconf.cacheEntries = cacheEntries;
    //sconf.debugLogPath = tagged Valid ("priv_scratchpad_" + integerToString(logID) + ".out");
    sconf.enableStatistics = tagged Valid ("priv_scratchpad_" + integerToString(logID) + "_stats_");

    // scratchpad
    MEMORY_IFC#(Bit#(t_addr_sz), Bit#(t_data_sz)) memory <- mkScratchpad(scratchpadID, sconf);

    // mem request fifo
    FIFOF#(Tuple3#(Bit#(t_addr_sz), Bit#(t_data_sz), Bool)) reqFifo <- mkSizedFIFOF(16);


    `ifdef PRIV_VERBOSE
    FIFO#(Bit#(32)) readStartCycle <- mkSizedFIFO(16);
    FIFO#(Bit#(32)) writeStartCycle <- mkSizedFIFO(16);

    FIFO#(Bit#(t_addr_sz)) readAddrFifo <- mkSizedFIFO(16);
    `endif


    Reg#(Bit#(32)) cycle <- mkReg(0);


    // =======================================================================
    //
    // Rules
    //
    // =======================================================================

    (* fire_when_enabled *)
    rule reqNotFull ( reqFifo.notFull );
        bus.reqNotFull();
    endrule



    // ====================================================================
    //
    // memory write.
    //
    // ====================================================================/

    (* fire_when_enabled *) 
    rule writeReq ( bus.writeReqEn );

        Bit#(t_addr_sz) a = bus.reqAddr | (fromInteger(logID) * (1<<`MEM_TEST_SHIFT) );
        Bit#(t_data_sz) d = bus.writeData;
        reqFifo.enq(tuple3(a,d,True));

        `ifdef PRIV_VERBOSE
        writeStartCycle.enq(cycle);
        $display("[%d] bus%d write request: addr = %x",cycle,logID,a);
        `endif
    endrule


    rule memWriteSPReq ( reqFifo.notEmpty && tpl_3(reqFifo.first()) );        

        match {.a, .d, .is_write} = reqFifo.first();
        reqFifo.deq;

        memory.write(a, d);

        `ifdef PRIV_VERBOSE
        $display("[%d] bus%d write response: addr = %x, data = %d, latency = %d",cycle,logID,a,d,cycle-writeStartCycle.first);
        writeStartCycle.deq;
        `endif
    endrule


    // ====================================================================
    //
    // memory read.
    //
    // ====================================================================/

    (* fire_when_enabled *) 
    rule readReq (!bus.writeReqEn);

        Bit#(t_addr_sz) a = bus.reqAddr | (fromInteger(logID) * (1<<`MEM_TEST_SHIFT) ) ;
        reqFifo.enq(tuple3(a,?,False));

        `ifdef PRIV_VERBOSE
        readStartCycle.enq(cycle);
        $display("[%d] bus%d read request: addr = %x",cycle,logID,a);
        `endif
    endrule


    rule memReadSPReq ( reqFifo.notEmpty && !tpl_3(reqFifo.first()) );        

        match {.a, .d, .is_write} = reqFifo.first();
        reqFifo.deq;

        memory.readReq(a);  

        `ifdef PRIV_VERBOSE
        readAddrFifo.enq(a);
        `endif

    endrule


    // receive read response
    rule memReadSPRespResp (True);

        Bit#(t_data_sz) resp <- memory.readRsp();
        bus.readRsp(resp);

        `ifdef PRIV_VERBOSE
        $display("[%d] bus%d read response: addr = %x, data = %d, latency = %d",cycle,logID,readAddrFifo.first,resp,cycle-readStartCycle.first);
        readStartCycle.deq;
        readAddrFifo.deq;
        `endif
    endrule


    // ====================================================================
    //
    // stats.
    //
    // ====================================================================/

    `ifdef PRIV_VERBOSE    
    (* fire_when_enabled *)
    rule cycle_count (True);
        cycle <= cycle + 1;
    endrule
    `endif



endmodule

