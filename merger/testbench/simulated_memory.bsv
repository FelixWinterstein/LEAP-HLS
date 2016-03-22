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
import RegFile::*;
import MyIP::*;


`define PRIV_VERBOSE
typedef 2 MEM_LATENCY;  // shouldn't be less than 1

interface PRIVATESP_IFC#(type t_addr, type t_data);
endinterface

module mkSimulatedMemory#( HLS_AP_BUS_IFC#(Bit#(t_data_sz),Bit#(t_addr_sz)) bus, Integer scratchpadID)
    // interface:
    (PRIVATESP_IFC#(Bit#(t_addr_sz), Bit#(t_data_sz)));


    
     // simulate memories
    RegFile#(Bit#(t_addr_sz), Bit#(t_data_sz)) memory <- mkRegFileLoad("freelist_initialization.hex",0,255);

    // mem request fifo
    FIFOF#(Tuple3#(Bit#(t_addr_sz), Bit#(t_data_sz), Bool)) reqFifo <- mkSizedFIFOF(16);

    // mem response fifo
    FIFOF#(Bit#(t_data_sz)) readRspFifo <- mkSizedFIFOF(16);

    // simulate memory latency
    Reg#(UInt#(32)) writeLatCounter <- mkReg(0);
    Reg#(UInt#(32)) readLatCounter <- mkReg(0);


    // stats
    `ifdef PRIV_VERBOSE
    FIFO#(Bit#(32)) readStartCycle <- mkSizedFIFO(16);
    FIFO#(Bit#(32)) writeStartCycle <- mkSizedFIFO(16);
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

    (* fire_when_enabled *)
    rule rspNotEmpty ( readRspFifo.notEmpty );
        bus.rspNotEmpty();
    endrule    


    // ====================================================================
    //
    // memory write.
    //
    // ====================================================================/

    (* fire_when_enabled *)
    (* mutually_exclusive = "writeReq, memLatWrite" *) 
    rule writeReq ( bus.writeReqEn );

        Bit#(t_addr_sz) a = bus.reqAddr;
        Bit#(t_data_sz) d = bus.writeData;
        reqFifo.enq(tuple3(a,d,True));

        writeLatCounter <= 0;

        `ifdef PRIV_VERBOSE
        writeStartCycle.enq(cycle);
        $display("[%d] bus%d write request: addr = %d",cycle,scratchpadID,a);
        `endif
    endrule


    (* descending_urgency = "memWriteSPResp, memLatWrite" *)
    rule memWriteSPResp ( reqFifo.notEmpty && tpl_3(reqFifo.first()) && writeLatCounter >= fromInteger(valueOf(MEM_LATENCY)-1) );        

        match {.a, .d, .is_write} = reqFifo.first();
        reqFifo.deq;

        memory.upd(a, d);

        `ifdef PRIV_VERBOSE
        $display("[%d] bus%d write response: addr = %d, data = %d, latency = %d",cycle,scratchpadID,a,d,cycle-writeStartCycle.first);
        writeStartCycle.deq;
        `endif
    endrule



    // ====================================================================
    //
    // memory read.
    //
    // ====================================================================/

    (* fire_when_enabled *) 
    (* mutually_exclusive = "readReq, memLatRead" *)
    rule readReq (!bus.writeReqEn );

        Bit#(t_addr_sz) a = bus.reqAddr;
        reqFifo.enq(tuple3(a,?,False));

        readLatCounter <= 0;

        `ifdef PRIV_VERBOSE
        readStartCycle.enq(cycle);
        $display("[%d] bus%d read request: addr = %d",cycle,scratchpadID,a);
        `endif
    endrule


    (* descending_urgency = "memReadSPRespFifo, memLatRead" *)
    rule memReadSPRespFifo ( reqFifo.notEmpty && !tpl_3(reqFifo.first()) && readLatCounter >= fromInteger(valueOf(MEM_LATENCY)-1) );        

        match {.a, .d, .is_write} = reqFifo.first();
        reqFifo.deq;

        Bit#(t_data_sz) resp = memory.sub(a);

        readRspFifo.enq(resp);

        `ifdef PRIV_VERBOSE
        $display("[%d] bus%d read response: addr = %d, data = %d, latency = %d",cycle,scratchpadID,a,resp,cycle-readStartCycle.first);
        readStartCycle.deq;
        `endif

    endrule

   // forward read response to core
    rule memReadSPRespResp ( True ); // readRspFifo.notEmpty ??

        bus.readRsp(readRspFifo.first);
        readRspFifo.deq;

    endrule


    // ====================================================================
    //
    // memory latency.
    //
    // ====================================================================/

    rule memLatWrite ( reqFifo.notEmpty );        

        writeLatCounter <= writeLatCounter + 1;  

    endrule
    
    rule memLatRead ( reqFifo.notEmpty );        

        readLatCounter <= readLatCounter + 1;  

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

