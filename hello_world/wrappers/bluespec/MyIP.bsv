/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: MyIP.bsv
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

interface MY_IP_IFC#(type tpd, type tpa);
    // drive inputs/outputs via methods
   
    // ip ctrl
    // inputs
    method Action start();    
    // outputs
    method Bool ipReady();
    method Bool ipIdle();
    method Bool ipDone();

    // bus io
    // inputs
    method Action bus0ReqNotFull();
    method Action bus0RspNotEmpty();
    method Action bus0ReadRsp(tpd bus0_datain);

    method Action bus1ReqNotFull();
    method Action bus1RspNotEmpty();
    method Action bus1ReadRsp(tpd bus1_datain); 
 
    // outputs
    method tpa bus0ReqAddr();
    method tpa bus0ReqSize();
    method tpd bus0WriteData();
    method Bool bus0WriteReqEn();

    method tpa bus1ReqAddr();
    method tpa bus1ReqSize();
    method tpd bus1WriteData();
    method Bool bus1WriteReqEn();

endinterface

import "BVI" hello_world = module mkMyIP( 
    MY_IP_IFC#( Bit#(n0),Bit#(n1) ) );  

    // clock and reset
    default_clock clk;
    default_reset rst_RST_N;

    input_clock clk (ap_clk) <- exposeCurrentClock;
    input_reset rst_RST_N (ap_rst_n) clocked_by(clk) <- exposeCurrentReset;


    // make signals in verilog to method arguments
    // ip ctrl
    // inputs
    method                start() enable(ap_start);
    // outputs
    method ap_idle        ipIdle ();
    method ap_ready       ipReady ();
    method ap_done        ipDone ();  

    // bus io
    // inputs
    method bus0ReqNotFull() enable(bus0_req_full_n);
    method bus0RspNotEmpty() enable(bus0_rsp_empty_n);
    method bus0ReadRsp(bus0_datain) enable( (*inhigh*) V_UNUSED0) ready(bus0_rsp_read);      

    method bus1ReqNotFull() enable(bus1_req_full_n);
    method bus1RspNotEmpty() enable(bus1_rsp_empty_n);
    method bus1ReadRsp(bus1_datain) enable( (*inhigh*) V_UNUSED1) ready(bus1_rsp_read);

    // outputs
    method bus0_address bus0ReqAddr() ready(bus0_req_write);
    method bus0_size bus0ReqSize() ready(bus0_req_write);
    method bus0_dataout bus0WriteData() ready(bus0_req_write);
    method bus0_req_din bus0WriteReqEn() ready(bus0_req_write); 

    method bus1_address bus1ReqAddr() ready(bus1_req_write);
    method bus1_size bus1ReqSize() ready(bus1_req_write);
    method bus1_dataout bus1WriteData() ready(bus1_req_write);
    method bus1_req_din bus1WriteReqEn() ready(bus1_req_write); 


    // tell the compiler all the combinational paths from input to output
    //... not now ...



    // scheduling
    schedule (
                start,
                ipReady,
                ipIdle,
                ipDone,
                bus0ReqNotFull,
                bus0RspNotEmpty,
                bus0ReadRsp,
                bus0ReqAddr,
                bus0ReqSize,
                bus0WriteData,
                bus0WriteReqEn,
                bus1ReqNotFull,
                bus1RspNotEmpty,    
                bus1ReadRsp,
                bus1ReqAddr,
                bus1ReqSize,
                bus1WriteData,
                bus1WriteReqEn
    ) CF (
                start,
                ipReady,
                ipIdle,
                ipDone,
                bus0ReqNotFull,
                bus0RspNotEmpty,
                bus0ReadRsp,
                bus0ReqAddr,
                bus0ReqSize,
                bus0WriteData,
                bus0WriteReqEn,
                bus1ReqNotFull,
                bus1RspNotEmpty,
                bus1ReadRsp,
                bus1ReqAddr,
                bus1ReqSize,
                bus1WriteData,
                bus1WriteReqEn
    );


endmodule

// Vivado HLS ap_bus interface
interface HLS_AP_BUS_IFC#(type tpd, type tpa);
    method Action reqNotFull();
    method Action rspNotEmpty();
    method Action readRsp( tpd resp);
    method tpa reqAddr();
    method tpa reqSize();
    method tpd writeData();
    method Bool writeReqEn();
endinterface

// MyIP with memory bus interface
interface MY_IP_WITH_MEM_BUS_IFC#( type tpd, type tpa );
    // ip ctrl
    method Action start();
    method Bool ipIdle();
    method Bool ipDone();
    method Bool ipReady();
    // ap bus ports
    interface HLS_AP_BUS_IFC#(tpd, tpa) busPort0;
    interface HLS_AP_BUS_IFC#(tpd, tpa) busPort1;
endinterface



module mkMyIPWithMemBus ( 
    MY_IP_WITH_MEM_BUS_IFC#( Bit#(n0), Bit#(n1) ) );

    MY_IP_IFC#( Bit#(n0),Bit#(n1) ) core <- mkMyIP;

    interface busPort0 =
        interface HLS_AP_BUS_IFC#( Bit#(n0), Bit#(n1) );
            method Action reqNotFull();
                core.bus0ReqNotFull();
            endmethod
            method Action rspNotEmpty();
                core.bus0RspNotEmpty();
            endmethod
            method Action readRsp(Bit#(n0) resp);
                core.bus0ReadRsp(resp);
            endmethod
            method Bit#(n1) reqAddr() = core.bus0ReqAddr();
            method Bit#(n1) reqSize() = core.bus0ReqSize();
            method Bit#(n0) writeData() = core.bus0WriteData();
            method Bool writeReqEn() = core.bus0WriteReqEn();
        endinterface;

    interface busPort1 =
        interface HLS_AP_BUS_IFC#( Bit#(n0), Bit#(n1) );
            method Action reqNotFull();
                core.bus1ReqNotFull();
            endmethod
            method Action rspNotEmpty();
                core.bus1RspNotEmpty();
            endmethod
            method Action readRsp(Bit#(n0) resp);
                core.bus1ReadRsp(resp);
            endmethod
            method Bit#(n1) reqAddr() = core.bus1ReqAddr();
            method Bit#(n1) reqSize() = core.bus1ReqSize();
            method Bit#(n0) writeData() = core.bus1WriteData();
            method Bool writeReqEn() = core.bus1WriteReqEn();
        endinterface;

    method Action start();
        core.start();
    endmethod

    method Bool ipIdle() = core.ipIdle();
    method Bool ipDone() = core.ipDone();
    method Bool ipReady() = core.ipReady();

endmodule
