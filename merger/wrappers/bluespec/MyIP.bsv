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

interface MyIP#(type tpd_io, type tpd_bus, type tpa);
    // drive inputs/outputs via methods
   
    // ip ctrl
    // inputs
    method Action start(); 
    method Action setN(tpa n);   
    // outputs
    method Bool ipReady();
    method Bool ipIdle();
    method Bool ipDone();

    // fifo
    // inputs        
    (* always_enabled *)
    method Action data_in0(tpd_io val_r1_dout);
    method Action enDataIn0();
    method Action data_in1(tpd_io val_r2_dout);
    method Action enDataIn1();
    method Action data_in2(tpd_io val_r3_dout);
    method Action enDataIn2();
    method Action data_in3(tpd_io val_r4_dout);
    method Action enDataIn3();
    method Action enDataOut();
    // outputs
    method tpd_io data_out();

    // bus io
    // inputs
    method Action readData0(tpd_bus readReq_data0);
    method Action enWrite0();

    method Action readData4(tpa readReq_data4);
    method Action enWrite4();

    `ifndef REDUCE_PAR_TO_1
    method Action readData1(tpd_bus readReq_data1);
    method Action enWrite1();

    method Action readData2(tpd_bus readReq_data2);
    method Action enWrite2();

    method Action readData3(tpd_bus readReq_data3);
    method Action enWrite3();

    method Action readData5(tpa readReq_data5);
    method Action enWrite5();

    method Action readData6(tpa readReq_data6);
    method Action enWrite6();

    method Action readData7(tpa readReq_data7);
    method Action enWrite7();

    `endif
    // outputs
    method tpd_bus writeData0();
    method tpa writeAddr0();
    method tpa readRequest0();

    method tpa writeData4();
    method tpa writeAddr4();
    method tpa readRequest4();

    `ifndef REDUCE_PAR_TO_1
    method tpd_bus writeData1();
    method tpa writeAddr1();
    method tpa readRequest1();

    method tpd_bus writeData2();
    method tpa writeAddr2();
    method tpa readRequest2();

    method tpd_bus writeData3();
    method tpa writeAddr3();
    method tpa readRequest3();

    method tpa writeData5();
    method tpa writeAddr5();
    method tpa readRequest5();

    method tpa writeData6();
    method tpa writeAddr6();
    method tpa readRequest6();

    method tpa writeData7();
    method tpa writeAddr7();
    method tpa readRequest7();
    `endif
endinterface

import "BVI" merger_top_wrapper =
   module mkMyIP( MyIP#( Bit#(n1), Bit#(n2), Bit#(n3) ) );  


        // clock and reset
        default_clock clk;
        default_reset rst_RST_N;

        input_clock clk (ap_clk) <- exposeCurrentClock;
        input_reset rst_RST_N (ap_rst_n) clocked_by(clk) <- exposeCurrentReset;

        // make signals in verilog to method arguments
        // ip ctrl
        // inputs
        method                start() enable(ap_start);
        method                setN(n) enable( (*inhigh*) V_UNUSED0 );
        // outputs
        method ap_idle        ipIdle ();
        method ap_ready       ipReady ();
        method ap_done        ipDone ();

        // fifo
        // inputs
        method                enDataOut() enable(val_w_full_n);

        method                enDataIn0() enable(val_r1_empty_n);
        method data_in0(val_r1_dout) enable( (*inhigh*) V_UNUSED1) ready(val_r1_read);

        method                enDataIn1() enable(val_r2_empty_n);
        method data_in1(val_r2_dout) enable( (*inhigh*) V_UNUSED2) ready(val_r2_read);

        method                enDataIn2() enable(val_r3_empty_n);
        method data_in2(val_r3_dout) enable( (*inhigh*) V_UNUSED3) ready(val_r3_read);

        method                enDataIn3() enable(val_r4_empty_n);
        method data_in3(val_r4_dout) enable( (*inhigh*) V_UNUSED4) ready(val_r4_read);
        // outputs
        method val_w_din data_out() ready(val_w_write);

        // bus io
        // inputs
        method readData0(readReq_data0) enable( readAck0 );
        method enWrite0() enable( writeAck0 );

        method readData4(readReq_data4) enable( readAck4 );
        method enWrite4() enable( writeAck4 );

        `ifndef REDUCE_PAR_TO_1
        method readData1(readReq_data1) enable( readAck1 );
        method enWrite1() enable( writeAck1 );

        method readData2(readReq_data2) enable( readAck2 );
        method enWrite2() enable( writeAck2 );

        method readData3(readReq_data3) enable( readAck3 );
        method enWrite3() enable( writeAck3 );

        method readData5(readReq_data5) enable( readAck5 );
        method enWrite5() enable( writeAck5 );

        method readData6(readReq_data6) enable( readAck6 );
        method enWrite6() enable( writeAck6 );

        method readData7(readReq_data7) enable( readAck7 );
        method enWrite7() enable( writeAck7 );

        `endif
        // outputs
        method writeReq_data0 writeData0() ready(writeReq0);
        method writeReq_addr0 writeAddr0() ready(writeReq0);
        method readReq_addr0 readRequest0() ready(readReq0);

        method writeReq_data4 writeData4() ready(writeReq4);
        method writeReq_addr4 writeAddr4() ready(writeReq4);
        method readReq_addr4 readRequest4() ready(readReq4);

        `ifndef REDUCE_PAR_TO_1
        method writeReq_data1 writeData1() ready(writeReq1);
        method writeReq_addr1 writeAddr1() ready(writeReq1);
        method readReq_addr1 readRequest1() ready(readReq1);

        method writeReq_data2 writeData2() ready(writeReq2);
        method writeReq_addr2 writeAddr2() ready(writeReq2);
        method readReq_addr2 readRequest2() ready(readReq2);

        method writeReq_data3 writeData3() ready(writeReq3);
        method writeReq_addr3 writeAddr3() ready(writeReq3);
        method readReq_addr3 readRequest3() ready(readReq3);

        method writeReq_data5 writeData5() ready(writeReq5);
        method writeReq_addr5 writeAddr5() ready(writeReq5);
        method readReq_addr5 readRequest5() ready(readReq5);

        method writeReq_data6 writeData6() ready(writeReq6);
        method writeReq_addr6 writeAddr6() ready(writeReq6);
        method readReq_addr6 readRequest6() ready(readReq6);

        method writeReq_data7 writeData7() ready(writeReq7);
        method writeReq_addr7 writeAddr7() ready(writeReq7);
        method readReq_addr7 readRequest7() ready(readReq7);
        `endif

        // tell the compiler all the combinational paths from input to output
        //... not now ...

        // scheduling
        schedule (  
                    start,
                    setN,
                    ipDone, 
                    ipIdle, 
                    ipReady,
                    enDataIn0,
                    enDataIn1,
                    enDataIn2,
                    enDataIn3,
                    enDataOut,
                    data_in0,
                    data_in1,
                    data_in2,
                    data_in3,                    
                    enWrite0,
                    readData0,
                    writeData0,
                    writeAddr0,
                    readRequest0,
                    enWrite4,
                    readData4,
                    writeData4,
                    writeAddr4,
                    readRequest4,
                    `ifndef REDUCE_PAR_TO_1
                    enWrite1,
                    readData1,
                    writeData1,
                    writeAddr1,
                    readRequest1,
                    enWrite2,
                    readData2,
                    writeData2,
                    writeAddr2,
                    readRequest2,
                    enWrite3,
                    readData3,
                    writeData3,
                    writeAddr3,
                    readRequest3,
                    enWrite5,
                    readData5,
                    writeData5,
                    writeAddr5,
                    readRequest5,
                    enWrite6,
                    readData6,
                    writeData6,
                    writeAddr6,
                    readRequest6,
                    enWrite7,
                    readData7,
                    writeData7,
                    writeAddr7,
                    readRequest7,
                    `endif
                    data_out
        ) CF       (  
                    start,
                    setN,
                    ipDone, 
                    ipIdle, 
                    ipReady,
                    enDataIn0,
                    enDataIn1,
                    enDataIn2,
                    enDataIn3,
                    enDataOut,
                    data_in0,
                    data_in1,
                    data_in2,
                    data_in3,                    
                    enWrite0,
                    readData0,
                    writeData0,
                    writeAddr0,
                    readRequest0,
                    enWrite4,
                    readData4,
                    writeData4,
                    writeAddr4,
                    readRequest4,
                    `ifndef REDUCE_PAR_TO_1
                    enWrite1,
                    readData1,
                    writeData1,
                    writeAddr1,
                    readRequest1,
                    enWrite2,
                    readData2,
                    writeData2,
                    writeAddr2,
                    readRequest2,
                    enWrite3,
                    readData3,
                    writeData3,
                    writeAddr3,
                    readRequest3,
                    enWrite5,
                    readData5,
                    writeData5,
                    writeAddr5,
                    readRequest5,
                    enWrite6,
                    readData6,
                    writeData6,
                    writeAddr6,
                    readRequest6,
                    enWrite7,
                    readData7,
                    writeData7,
                    writeAddr7,
                    readRequest7,
                    `endif
                    data_out
        );

   endmodule
