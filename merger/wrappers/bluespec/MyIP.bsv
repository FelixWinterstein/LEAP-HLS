/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: MyIP.bsv
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

//`define REDUCE_PAR_TO_1

interface MY_IP_IFC#(type tpd, type tpa, type tpd_io);
    // drive inputs/outputs via methods
   
    /*** ip ctrl ***/
    // inputs
    method Action start();    
    method Action setN(tpa n);
    // outputs
    method Bool ipReady();
    method Bool ipIdle();
    method Bool ipDone();

    /*** fifo ***/
    // inputs        
    method Action data_in0(tpd_io val_r0_dout);
    method Action enDataIn0();
    method Action data_in1(tpd_io val_r1_dout);
    method Action enDataIn1();
    method Action data_in2(tpd_io val_r2_dout);
    method Action enDataIn2();
    method Action data_in3(tpd_io val_r3_dout);
    method Action enDataIn3();
    method Action enDataOut0();
    // outputs
    method tpd_io data_out0();

    /*** bus io ***/
    // inputs
    method Action bus0ReqNotFull();
    method Action bus0RspNotEmpty();
    method Action bus0ReadRsp(tpa freelist_bus_0_datain);

    method Action bus4ReqNotFull();
    method Action bus4RspNotEmpty();
    method Action bus4ReadRsp(tpd data_bus_0_datain);

    `ifndef REDUCE_PAR_TO_1
    method Action bus1ReqNotFull();
    method Action bus1RspNotEmpty();
    method Action bus1ReadRsp(tpa freelist_bus_1_datain); 
    method Action bus2ReqNotFull();
    method Action bus2RspNotEmpty();
    method Action bus2ReadRsp(tpa freelist_bus_2_datain);
    method Action bus3ReqNotFull();
    method Action bus3RspNotEmpty();
    method Action bus3ReadRsp(tpa freelist_bus_3_datain);

    method Action bus5ReqNotFull();
    method Action bus5RspNotEmpty();
    method Action bus5ReadRsp(tpd data_bus_1_datain);
    method Action bus6ReqNotFull();
    method Action bus6RspNotEmpty();
    method Action bus6ReadRsp(tpd data_bus_2_datain );
    method Action bus7ReqNotFull();
    method Action bus7RspNotEmpty();
    method Action bus7ReadRsp(tpd data_bus_3_datain);
    `endif
 
    // outputs
    method tpa bus0ReqAddr();
    method tpa bus0ReqSize();
    method tpa bus0WriteData();
    method Bool bus0WriteReqEn();

    method tpa bus4ReqAddr();
    method tpa bus4ReqSize();
    method tpd bus4WriteData();
    method Bool bus4WriteReqEn();

    `ifndef REDUCE_PAR_TO_1
    method tpa bus1ReqAddr();
    method tpa bus1ReqSize();
    method tpa bus1WriteData();
    method Bool bus1WriteReqEn();
    method tpa bus2ReqAddr();
    method tpa bus2ReqSize();
    method tpa bus2WriteData();
    method Bool bus2WriteReqEn();
    method tpa bus3ReqAddr();
    method tpa bus3ReqSize();
    method tpa bus3WriteData();
    method Bool bus3WriteReqEn();

    method tpa bus5ReqAddr();
    method tpa bus5ReqSize();
    method tpd bus5WriteData();
    method Bool bus5WriteReqEn();
    method tpa bus6ReqAddr();
    method tpa bus6ReqSize();
    method tpd bus6WriteData();
    method Bool bus6WriteReqEn();
    method tpa bus7ReqAddr();
    method tpa bus7ReqSize();
    method tpd bus7WriteData();
    method Bool bus7WriteReqEn();
    `endif

endinterface


import "BVI" merger_top = module mkMyIP( 
    MY_IP_IFC#( Bit#(n0),Bit#(n1),Bit#(n2) ) );  

    // clock and reset
    default_clock clk;
    default_reset rst_RST_N;

    input_clock clk (ap_clk) <- exposeCurrentClock;
    input_reset rst_RST_N (ap_rst_n) clocked_by(clk) <- exposeCurrentReset;


    // make signals in verilog to method arguments
    /*** ip ctrl ***/
    // inputs
    method                start() enable(ap_start);
    method                setN(n) enable( (*inhigh*) V_UNUSED0 );
    // outputs
    method ap_idle        ipIdle ();
    method ap_ready       ipReady ();
    method ap_done        ipDone ();  


    /*** fifo ***/
    // inputs
    method                enDataOut0() enable(val_w0_full_n);

    method                enDataIn0() enable(val_r0_empty_n);
    method data_in0(val_r0_dout) enable( (*inhigh*) V_UNUSED1) ready(val_r0_read);

    method                enDataIn1() enable(val_r1_empty_n);
    method data_in1(val_r1_dout) enable( (*inhigh*) V_UNUSED2) ready(val_r1_read);

    method                enDataIn2() enable(val_r2_empty_n);
    method data_in2(val_r2_dout) enable( (*inhigh*) V_UNUSED3) ready(val_r2_read);

    method                enDataIn3() enable(val_r3_empty_n);
    method data_in3(val_r3_dout) enable( (*inhigh*) V_UNUSED4) ready(val_r3_read);
    // outputs
    method val_w0_din data_out0() ready(val_w0_write);


    /*** bus io ***/
    // inputs
    method bus0ReqNotFull() enable(freelist_bus_0_req_full_n);
    method bus0RspNotEmpty() enable(freelist_bus_0_rsp_empty_n);
    method bus0ReadRsp(freelist_bus_0_datain) enable( (*inhigh*) V_UNUSED5) ready(freelist_bus_0_rsp_read); 
    method bus4ReqNotFull() enable(data_bus_0_req_full_n);
    method bus4RspNotEmpty() enable(data_bus_0_rsp_empty_n);     
    method bus4ReadRsp(data_bus_0_datain) enable( (*inhigh*) V_UNUSED6) ready(data_bus_0_rsp_read);    

    `ifndef REDUCE_PAR_TO_1
    method bus1ReqNotFull() enable(freelist_bus_1_req_full_n);
    method bus1RspNotEmpty() enable(freelist_bus_1_rsp_empty_n);
    method bus1ReadRsp(freelist_bus_1_datain) enable( (*inhigh*) V_UNUSED7) ready(freelist_bus_1_rsp_read); 
    method bus2ReqNotFull() enable(freelist_bus_2_req_full_n);
    method bus2RspNotEmpty() enable(freelist_bus_2_rsp_empty_n);
    method bus2ReadRsp(freelist_bus_2_datain) enable( (*inhigh*) V_UNUSED8) ready(freelist_bus_2_rsp_read); 
    method bus3ReqNotFull() enable(freelist_bus_3_req_full_n);
    method bus3RspNotEmpty() enable(freelist_bus_3_rsp_empty_n);
    method bus3ReadRsp(freelist_bus_3_datain) enable( (*inhigh*) V_UNUSED9) ready(freelist_bus_3_rsp_read); 

    method bus5ReqNotFull() enable(data_bus_1_req_full_n);
    method bus5RspNotEmpty() enable(data_bus_1_rsp_empty_n);     
    method bus5ReadRsp(data_bus_1_datain) enable( (*inhigh*) V_UNUSED10) ready(data_bus_1_rsp_read); 
    method bus6ReqNotFull() enable(data_bus_2_req_full_n);
    method bus6RspNotEmpty() enable(data_bus_2_rsp_empty_n);     
    method bus6ReadRsp(data_bus_2_datain) enable( (*inhigh*) V_UNUSED11) ready(data_bus_2_rsp_read); 
    method bus7ReqNotFull() enable(data_bus_3_req_full_n);
    method bus7RspNotEmpty() enable(data_bus_3_rsp_empty_n);     
    method bus7ReadRsp(data_bus_3_datain) enable( (*inhigh*) V_UNUSED12) ready(data_bus_3_rsp_read); 
    `endif

    // outputs
    method freelist_bus_0_address bus0ReqAddr() ready(freelist_bus_0_req_write);
    method freelist_bus_0_size bus0ReqSize() ready(freelist_bus_0_req_write);
    method freelist_bus_0_dataout bus0WriteData() ready(freelist_bus_0_req_write);
    method freelist_bus_0_req_din bus0WriteReqEn() ready(freelist_bus_0_req_write); 
    method data_bus_0_address bus4ReqAddr() ready(data_bus_0_req_write);
    method data_bus_0_size bus4ReqSize() ready(data_bus_0_req_write);
    method data_bus_0_dataout bus4WriteData() ready(data_bus_0_req_write);
    method data_bus_0_req_din bus4WriteReqEn() ready(data_bus_0_req_write);

    `ifndef REDUCE_PAR_TO_1
    method freelist_bus_1_address bus1ReqAddr() ready(freelist_bus_1_req_write);
    method freelist_bus_1_size bus1ReqSize() ready(freelist_bus_1_req_write);
    method freelist_bus_1_dataout bus1WriteData() ready(freelist_bus_1_req_write);
    method freelist_bus_1_req_din bus1WriteReqEn() ready(freelist_bus_1_req_write); 
    method freelist_bus_2_address bus2ReqAddr() ready(freelist_bus_2_req_write);
    method freelist_bus_2_size bus2ReqSize() ready(freelist_bus_2_req_write);
    method freelist_bus_2_dataout bus2WriteData() ready(freelist_bus_2_req_write);
    method freelist_bus_2_req_din bus2WriteReqEn() ready(freelist_bus_2_req_write);
    method freelist_bus_3_address bus3ReqAddr() ready(freelist_bus_3_req_write);
    method freelist_bus_3_size bus3ReqSize() ready(freelist_bus_3_req_write);
    method freelist_bus_3_dataout bus3WriteData() ready(freelist_bus_3_req_write);
    method freelist_bus_3_req_din bus3WriteReqEn() ready(freelist_bus_3_req_write);

    method data_bus_1_address bus5ReqAddr() ready(data_bus_1_req_write);
    method data_bus_1_size bus5ReqSize() ready(data_bus_1_req_write);
    method data_bus_1_dataout bus5WriteData() ready(data_bus_1_req_write);
    method data_bus_1_req_din bus5WriteReqEn() ready(data_bus_1_req_write);
    method data_bus_2_address bus6ReqAddr() ready(data_bus_2_req_write);
    method data_bus_2_size bus6ReqSize() ready(data_bus_2_req_write);
    method data_bus_2_dataout bus6WriteData() ready(data_bus_2_req_write);
    method data_bus_2_req_din bus6WriteReqEn() ready(data_bus_2_req_write);
    method data_bus_3_address bus7ReqAddr() ready(data_bus_3_req_write);
    method data_bus_3_size bus7ReqSize() ready(data_bus_3_req_write);
    method data_bus_3_dataout bus7WriteData() ready(data_bus_3_req_write);
    method data_bus_3_req_din bus7WriteReqEn() ready(data_bus_3_req_write);

    `endif


    // tell the compiler all the combinational paths from input to output
    //... not now ...



    // scheduling
    schedule (
                start,
                setN,
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
                bus4ReqNotFull,
                bus4RspNotEmpty,
                bus4ReadRsp,
                bus4ReqAddr,
                bus4ReqSize,
                bus4WriteData,
                bus4WriteReqEn,
                `ifndef REDUCE_PAR_TO_1
                bus1ReqNotFull,
                bus1RspNotEmpty,
                bus1ReadRsp,
                bus1ReqAddr,
                bus1ReqSize,
                bus1WriteData,
                bus1WriteReqEn,
                bus2ReqNotFull,
                bus2RspNotEmpty,
                bus2ReadRsp,
                bus2ReqAddr,
                bus2ReqSize,
                bus2WriteData,
                bus2WriteReqEn,
                bus3ReqNotFull,
                bus3RspNotEmpty,
                bus3ReadRsp,
                bus3ReqAddr,
                bus3ReqSize,
                bus3WriteData,
                bus3WriteReqEn,
                bus5ReqNotFull,
                bus5RspNotEmpty,
                bus5ReadRsp,
                bus5ReqAddr,
                bus5ReqSize,
                bus5WriteData,
                bus5WriteReqEn,
                bus6ReqNotFull,
                bus6RspNotEmpty,
                bus6ReadRsp,
                bus6ReqAddr,
                bus6ReqSize,
                bus6WriteData,
                bus6WriteReqEn,
                bus7ReqNotFull,
                bus7RspNotEmpty,
                bus7ReadRsp,
                bus7ReqAddr,
                bus7ReqSize,
                bus7WriteData,
                bus7WriteReqEn,
                `endif
                enDataIn0,
                enDataIn1,
                enDataIn2,
                enDataIn3,
                data_in0,
                data_in1,
                data_in2,
                data_in3,
                enDataOut0,
                data_out0
    ) CF (
                start,
                setN,
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
                bus4ReqNotFull,
                bus4RspNotEmpty,
                bus4ReadRsp,
                bus4ReqAddr,
                bus4ReqSize,
                bus4WriteData,
                bus4WriteReqEn,
                `ifndef REDUCE_PAR_TO_1
                bus1ReqNotFull,
                bus1RspNotEmpty,
                bus1ReadRsp,
                bus1ReqAddr,
                bus1ReqSize,
                bus1WriteData,
                bus1WriteReqEn,
                bus2ReqNotFull,
                bus2RspNotEmpty,
                bus2ReadRsp,
                bus2ReqAddr,
                bus2ReqSize,
                bus2WriteData,
                bus2WriteReqEn,
                bus3ReqNotFull,
                bus3RspNotEmpty,
                bus3ReadRsp,
                bus3ReqAddr,
                bus3ReqSize,
                bus3WriteData,
                bus3WriteReqEn,
                bus5ReqNotFull,
                bus5RspNotEmpty,
                bus5ReadRsp,
                bus5ReqAddr,
                bus5ReqSize,
                bus5WriteData,
                bus5WriteReqEn,
                bus6ReqNotFull,
                bus6RspNotEmpty,
                bus6ReadRsp,
                bus6ReqAddr,
                bus6ReqSize,
                bus6WriteData,
                bus6WriteReqEn,
                bus7ReqNotFull,
                bus7RspNotEmpty,
                bus7ReadRsp,
                bus7ReqAddr,
                bus7ReqSize,
                bus7WriteData,
                bus7WriteReqEn,
                `endif
                enDataIn0,
                enDataIn1,
                enDataIn2,
                enDataIn3,
                data_in0,
                data_in1,
                data_in2,
                data_in3,
                enDataOut0,
                data_out0
    );


endmodule


/*** bundle interfaces ***/

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

// Vivado HLS ap_fifo_in interface
interface HLS_AP_FIFO_IN_IFC#(type tpd_io);
    method Action data_in(tpd_io d);
    method Action enDataIn();
endinterface

// Vivado HLS ap_fifo_out interface
interface HLS_AP_FIFO_OUT_IFC#(type tpd_io);
    method Action enDataOut();
    method tpd_io data_out();
endinterface

// MyIP with memory bus interface
interface MY_IP_WITH_BUNDLES_IFC#( type tpd, type tpa, type tpd_io );
    // ip ctrl
    method Action start();
    method Action setN(tpa n);
    method Bool ipIdle();
    method Bool ipDone();
    method Bool ipReady();

    // ap fifo ports 
    interface HLS_AP_FIFO_IN_IFC#(tpd_io) fifoInPort0;
    interface HLS_AP_FIFO_IN_IFC#(tpd_io) fifoInPort1;
    interface HLS_AP_FIFO_IN_IFC#(tpd_io) fifoInPort2;
    interface HLS_AP_FIFO_IN_IFC#(tpd_io) fifoInPort3;
    interface HLS_AP_FIFO_OUT_IFC#(tpd_io) fifoOutPort0;
    
    // ap bus ports
    interface HLS_AP_BUS_IFC#(tpa, tpa) busPort0;
    interface HLS_AP_BUS_IFC#(tpd, tpa) busPort4;
    `ifndef REDUCE_PAR_TO_1
    interface HLS_AP_BUS_IFC#(tpa, tpa) busPort1;
    interface HLS_AP_BUS_IFC#(tpa, tpa) busPort2;
    interface HLS_AP_BUS_IFC#(tpa, tpa) busPort3;

    interface HLS_AP_BUS_IFC#(tpd, tpa) busPort5;
    interface HLS_AP_BUS_IFC#(tpd, tpa) busPort6;
    interface HLS_AP_BUS_IFC#(tpd, tpa) busPort7;
    `endif
endinterface



module mkMyIPWithBundles ( 
    MY_IP_WITH_BUNDLES_IFC#( Bit#(n0), Bit#(n1), Bit#(n2) ) );

    MY_IP_IFC#( Bit#(n0),Bit#(n1),Bit#(n2) ) core <- mkMyIP;

    interface fifoInPort0 =
        interface HLS_AP_FIFO_IN_IFC#( Bit#(n2) );
            method Action enDataIn();
                core.enDataIn0();
            endmethod
            method Action data_in(Bit#(n2) d);
                core.data_in0(d);
            endmethod
        endinterface;

    interface fifoInPort1 =
        interface HLS_AP_FIFO_IN_IFC#( Bit#(n2) );
            method Action enDataIn();
                core.enDataIn1();
            endmethod
            method Action data_in(Bit#(n2) d);
                core.data_in1(d);
            endmethod
        endinterface;

    interface fifoInPort2 =
        interface HLS_AP_FIFO_IN_IFC#( Bit#(n2) );
            method Action enDataIn();
                core.enDataIn2();
            endmethod
            method Action data_in(Bit#(n2) d);
                core.data_in2(d);
            endmethod
        endinterface;

    interface fifoInPort3 =
        interface HLS_AP_FIFO_IN_IFC#( Bit#(n2) );
            method Action enDataIn();
                core.enDataIn3();
            endmethod
            method Action data_in(Bit#(n2) d);
                core.data_in3(d);
            endmethod
        endinterface;

    interface fifoOutPort0 =
        interface HLS_AP_FIFO_OUT_IFC#( Bit#(n2) );
            method Action enDataOut();
                core.enDataOut0();
            endmethod
            method Bit#(n2) data_out() = core.data_out0();
        endinterface;


    interface busPort0 =
        interface HLS_AP_BUS_IFC#( Bit#(n1), Bit#(n1) );
            method Action reqNotFull();
                core.bus0ReqNotFull();
            endmethod
            method Action rspNotEmpty();
                core.bus0RspNotEmpty();
            endmethod
            method Action readRsp(Bit#(n1) resp);
                core.bus0ReadRsp(resp);
            endmethod
            method Bit#(n1) reqAddr() = core.bus0ReqAddr();
            method Bit#(n1) reqSize() = core.bus0ReqSize();
            method Bit#(n1) writeData() = core.bus0WriteData();
            method Bool writeReqEn() = core.bus0WriteReqEn();
        endinterface;

    interface busPort4 =
        interface HLS_AP_BUS_IFC#( Bit#(n0), Bit#(n1) );
            method Action reqNotFull();
                core.bus4ReqNotFull();
            endmethod
            method Action rspNotEmpty();
                core.bus4RspNotEmpty();
            endmethod
            method Action readRsp(Bit#(n0) resp);
                core.bus4ReadRsp(resp);
            endmethod
            method Bit#(n1) reqAddr() = core.bus4ReqAddr();
            method Bit#(n1) reqSize() = core.bus4ReqSize();
            method Bit#(n0) writeData() = core.bus4WriteData();
            method Bool writeReqEn() = core.bus4WriteReqEn();
        endinterface;

    `ifndef REDUCE_PAR_TO_1

    interface busPort1 =
        interface HLS_AP_BUS_IFC#( Bit#(n1), Bit#(n1) );
            method Action reqNotFull();
                core.bus1ReqNotFull();
            endmethod
            method Action rspNotEmpty();
                core.bus1RspNotEmpty();
            endmethod
            method Action readRsp(Bit#(n1) resp);
                core.bus1ReadRsp(resp);
            endmethod
            method Bit#(n1) reqAddr() = core.bus1ReqAddr();
            method Bit#(n1) reqSize() = core.bus1ReqSize();
            method Bit#(n1) writeData() = core.bus1WriteData();
            method Bool writeReqEn() = core.bus1WriteReqEn();
        endinterface;

    interface busPort2 =
        interface HLS_AP_BUS_IFC#( Bit#(n1), Bit#(n1) );
            method Action reqNotFull();
                core.bus2ReqNotFull();
            endmethod
            method Action rspNotEmpty();
                core.bus2RspNotEmpty();
            endmethod
            method Action readRsp(Bit#(n1) resp);
                core.bus2ReadRsp(resp);
            endmethod
            method Bit#(n1) reqAddr() = core.bus2ReqAddr();
            method Bit#(n1) reqSize() = core.bus2ReqSize();
            method Bit#(n1) writeData() = core.bus2WriteData();
            method Bool writeReqEn() = core.bus2WriteReqEn();
        endinterface;

    interface busPort3 =
        interface HLS_AP_BUS_IFC#( Bit#(n1), Bit#(n1) );
            method Action reqNotFull();
                core.bus3ReqNotFull();
            endmethod
            method Action rspNotEmpty();
                core.bus3RspNotEmpty();
            endmethod
            method Action readRsp(Bit#(n1) resp);
                core.bus3ReadRsp(resp);
            endmethod
            method Bit#(n1) reqAddr() = core.bus3ReqAddr();
            method Bit#(n1) reqSize() = core.bus3ReqSize();
            method Bit#(n1) writeData() = core.bus3WriteData();
            method Bool writeReqEn() = core.bus3WriteReqEn();
        endinterface;

    interface busPort5 =
        interface HLS_AP_BUS_IFC#( Bit#(n0), Bit#(n1) );
            method Action reqNotFull();
                core.bus5ReqNotFull();
            endmethod
            method Action rspNotEmpty();
                core.bus5RspNotEmpty();
            endmethod
            method Action readRsp(Bit#(n0) resp);
                core.bus5ReadRsp(resp);
            endmethod
            method Bit#(n1) reqAddr() = core.bus5ReqAddr();
            method Bit#(n1) reqSize() = core.bus5ReqSize();
            method Bit#(n0) writeData() = core.bus5WriteData();
            method Bool writeReqEn() = core.bus5WriteReqEn();
        endinterface;

    interface busPort6 =
        interface HLS_AP_BUS_IFC#( Bit#(n0), Bit#(n1) );
            method Action reqNotFull();
                core.bus6ReqNotFull();
            endmethod
            method Action rspNotEmpty();
                core.bus6RspNotEmpty();
            endmethod
            method Action readRsp(Bit#(n0) resp);
                core.bus6ReadRsp(resp);
            endmethod
            method Bit#(n1) reqAddr() = core.bus6ReqAddr();
            method Bit#(n1) reqSize() = core.bus6ReqSize();
            method Bit#(n0) writeData() = core.bus6WriteData();
            method Bool writeReqEn() = core.bus6WriteReqEn();
        endinterface;

    interface busPort7 =
        interface HLS_AP_BUS_IFC#( Bit#(n0), Bit#(n1) );
            method Action reqNotFull();
                core.bus7ReqNotFull();
            endmethod
            method Action rspNotEmpty();
                core.bus7RspNotEmpty();
            endmethod
            method Action readRsp(Bit#(n0) resp);
                core.bus7ReadRsp(resp);
            endmethod
            method Bit#(n1) reqAddr() = core.bus7ReqAddr();
            method Bit#(n1) reqSize() = core.bus7ReqSize();
            method Bit#(n0) writeData() = core.bus7WriteData();
            method Bool writeReqEn() = core.bus7WriteReqEn();
        endinterface;

    `endif

    method Action start();
        core.start();
    endmethod

    method Action setN(Bit#(n1) n);
        core.setN(n);
    endmethod

    method Bool ipIdle() = core.ipIdle();
    method Bool ipDone() = core.ipDone();
    method Bool ipReady() = core.ipReady();

endmodule



