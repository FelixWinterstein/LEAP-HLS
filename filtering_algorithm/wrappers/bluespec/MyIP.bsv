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
//`define REDUCE_PAR_TO_2
//`define CENTRE_BUFFER_ONCHIP




interface MyIP#(type tpd_in1, type tpd_in2, type tpd_in3, type tpd_in4, type tpd_out1, type tpd_out2, type tpd_bus0, type tpd_bus1, type tpd_bus2, type tpd_bus3, type tpd_bus4, type tpa); 

    // drive inputs/outputs via methods
   
    // ip ctrl
    // inputs
    method Action start(); 


    method Action setN(tpd_in2 n_V);   
    method Action setK(tpd_in3 k_V);   
    method Action setL(tpd_in2 l);   
    // outputs
    method Bool ipReady();
    method Bool ipIdle();
    method Bool ipDone();

    // fifo
    // inputs        
    (* always_enabled *)
    method Action i_node_data(tpd_in1 i_node_data_value_V_dout);
    method Action en_i_node_data();

    (* always_enabled *)
    method Action root(tpa root_V_dout);
    method Action en_root();

    (* always_enabled *)
    method Action cntr_pos_init(tpd_in4 cntr_pos_init_value_V_dout);
    method Action en_cntr_pos_init();

    method Action en_clusters_out();
    method Action en_distortion_out();
    // outputs
    method tpd_out1 clusters_out();
    method tpd_out2 distortion_out();

    // bus io
    // inputs
    method Action readData0_0(tpd_bus0 readReq_data0_0);
    method Action enWrite0_0();
    method Action readData0_1(tpd_bus1 readReq_data0_1);
    method Action enWrite0_1();
    method Action readData0_2(tpd_bus2 readReq_data0_2);
    method Action enWrite0_2();  
    `ifndef CENTRE_BUFFER_ONCHIP
    method Action readData0_3(tpd_bus3 readReq_data0_3);
    method Action enWrite0_3(); 
    `endif
    method Action readData0_4(tpd_bus4 readReq_data0_4);
    method Action enWrite0_4();  
  
    `ifndef REDUCE_PAR_TO_1
    method Action readData1_0(tpd_bus0 readReq_data1_0);
    method Action enWrite1_0();
    method Action readData1_1(tpd_bus1 readReq_data1_1);
    method Action enWrite1_1();
    method Action readData1_2(tpd_bus2 readReq_data1_2);
    method Action enWrite1_2();   
    `ifndef CENTRE_BUFFER_ONCHIP
    method Action readData1_3(tpd_bus3 readReq_data1_3);
    method Action enWrite1_3(); 
    `endif
    method Action readData1_4(tpd_bus4 readReq_data1_4);
    method Action enWrite1_4();  

    `ifndef REDUCE_PAR_TO_2
    method Action readData2_0(tpd_bus0 readReq_data2_0);
    method Action enWrite2_0();
    method Action readData2_1(tpd_bus1 readReq_data2_1);
    method Action enWrite2_1();
    method Action readData2_2(tpd_bus2 readReq_data2_2);
    method Action enWrite2_2();   
    `ifndef CENTRE_BUFFER_ONCHIP
    method Action readData2_3(tpd_bus3 readReq_data2_3);
    method Action enWrite2_3(); 
    `endif
    method Action readData2_4(tpd_bus4 readReq_data2_4);
    method Action enWrite2_4();  

    method Action readData3_0(tpd_bus0 readReq_data3_0);
    method Action enWrite3_0();
    method Action readData3_1(tpd_bus1 readReq_data3_1);
    method Action enWrite3_1();
    method Action readData3_2(tpd_bus2 readReq_data3_2);
    method Action enWrite3_2();  
    `ifndef CENTRE_BUFFER_ONCHIP
    method Action readData3_3(tpd_bus3 readReq_data3_3);
    method Action enWrite3_3(); 
    `endif 
    method Action readData3_4(tpd_bus4 readReq_data3_4);
    method Action enWrite3_4();  

    `endif
    `endif

    // outputs
    method tpd_bus0 writeData0_0();
    method tpa writeAddr0_0();
    method tpa readRequest0_0();
    method tpd_bus1 writeData0_1();
    method tpa writeAddr0_1();
    method tpa readRequest0_1();
    method tpd_bus2 writeData0_2();
    method tpa writeAddr0_2();
    method tpa readRequest0_2();
    `ifndef CENTRE_BUFFER_ONCHIP
    method tpd_bus3 writeData0_3();
    method tpa writeAddr0_3();
    method tpa readRequest0_3();
    method Bool accessCriticalRegion0();
    `endif
    method tpd_bus4 writeData0_4();
    method tpa writeAddr0_4();
    method tpa readRequest0_4();

    `ifndef REDUCE_PAR_TO_1
    method tpd_bus0 writeData1_0();
    method tpa writeAddr1_0();
    method tpa readRequest1_0();
    method tpd_bus1 writeData1_1();
    method tpa writeAddr1_1();
    method tpa readRequest1_1();
    method tpd_bus2 writeData1_2();
    method tpa writeAddr1_2();
    method tpa readRequest1_2();
    `ifndef CENTRE_BUFFER_ONCHIP
    method tpd_bus3 writeData1_3();
    method tpa writeAddr1_3();
    method tpa readRequest1_3();
    method Bool accessCriticalRegion1();
    `endif
    method tpd_bus4 writeData1_4();
    method tpa writeAddr1_4();
    method tpa readRequest1_4();

    `ifndef REDUCE_PAR_TO_2
    method tpd_bus0 writeData2_0();
    method tpa writeAddr2_0();
    method tpa readRequest2_0();
    method tpd_bus1 writeData2_1();
    method tpa writeAddr2_1();
    method tpa readRequest2_1();
    method tpd_bus2 writeData2_2();
    method tpa writeAddr2_2();
    method tpa readRequest2_2();
    `ifndef CENTRE_BUFFER_ONCHIP
    method tpd_bus3 writeData2_3();
    method tpa writeAddr2_3();
    method tpa readRequest2_3();
    method Bool accessCriticalRegion2();
    `endif
    method tpd_bus4 writeData2_4();
    method tpa writeAddr2_4();
    method tpa readRequest2_4();

    method tpd_bus0 writeData3_0();
    method tpa writeAddr3_0();
    method tpa readRequest3_0();
    method tpd_bus1 writeData3_1();
    method tpa writeAddr3_1();
    method tpa readRequest3_1();
    method tpd_bus2 writeData3_2();
    method tpa writeAddr3_2();
    method tpa readRequest3_2();
    `ifndef CENTRE_BUFFER_ONCHIP
    method tpd_bus3 writeData3_3();
    method tpa writeAddr3_3();
    method tpa readRequest3_3();
    method Bool accessCriticalRegion3();
    `endif
    method tpd_bus4 writeData3_4();
    method tpa writeAddr3_4();
    method tpa readRequest3_4();

    `endif
    `endif


endinterface

import "BVI" filtering_algorithm_top_wrapper = 
    module mkMyIP( MyIP#(    Bit#(n1), Bit#(n2), Bit#(n3), Bit#(n4), Bit#(n5), Bit#(n6), Bit#(n7), Bit#(n8), Bit#(n9), Bit#(n10), Bit#(n11), Bit#(n12) ) );  


        // clock and reset
        default_clock clk;
        default_reset rst_RST_N;

        input_clock clk (ap_clk) <- exposeCurrentClock;
        input_reset rst_RST_N (ap_rst_n) clocked_by(clk) <- exposeCurrentReset;

        // make signals in verilog to method arguments
        // ip ctrl
        // inputs
        method                start() enable(ap_start);

        method                setN(n_V) enable( (*inhigh*) V_UNUSED0 );
        method                setK(k_V) enable( (*inhigh*) V_UNUSED1 );
        method                setL(l) enable( (*inhigh*) V_UNUSED2 );

        // outputs
        method ap_idle        ipIdle ();
        method ap_ready       ipReady ();
        method ap_done        ipDone ();

        // fifo
        // inputs
        method                en_clusters_out() enable(clusters_out_value_V_full_n);
        method                en_distortion_out() enable(distortion_out_V_full_n);

        method                en_i_node_data() enable(i_node_data_value_V_empty_n);
        method i_node_data(i_node_data_value_V_dout) enable( (*inhigh*) V_UNUSED3) ready(i_node_data_value_V_read);

        method                en_root() enable(root_V_empty_n);
        method root(root_V_dout) enable( (*inhigh*) V_UNUSED4) ready(root_V_read);

        method                en_cntr_pos_init() enable(cntr_pos_init_value_V_empty_n);
        method cntr_pos_init(cntr_pos_init_value_V_dout) enable( (*inhigh*) V_UNUSED5) ready(cntr_pos_init_value_V_read);

        // outputs
        method clusters_out_value_V_din clusters_out() ready(clusters_out_value_V_write);
        method distortion_out_V_din distortion_out() ready(distortion_out_V_write);

        // bus io
        // inputs
        method readData0_0(readReq_data0_0) enable( readAck0_0 );
        method enWrite0_0() enable( writeAck0_0 );

        method readData0_1(readReq_data0_1) enable( readAck0_1 );
        method enWrite0_1() enable( writeAck0_1 );

        method readData0_2(readReq_data0_2) enable( readAck0_2 );
        method enWrite0_2() enable( writeAck0_2 );

        `ifndef CENTRE_BUFFER_ONCHIP
        method readData0_3(readReq_data0_3) enable( readAck0_3 );
        method enWrite0_3() enable( writeAck0_3 );
        `endif

        method readData0_4(readReq_data0_4) enable( readAck0_4 );
        method enWrite0_4() enable( writeAck0_4 );


        `ifndef REDUCE_PAR_TO_1
        method readData1_0(readReq_data1_0) enable( readAck1_0 );
        method enWrite1_0() enable( writeAck1_0 );

        method readData1_1(readReq_data1_1) enable( readAck1_1 );
        method enWrite1_1() enable( writeAck1_1 );

        method readData1_2(readReq_data1_2) enable( readAck1_2 );
        method enWrite1_2() enable( writeAck1_2 );

        `ifndef CENTRE_BUFFER_ONCHIP
        method readData1_3(readReq_data1_3) enable( readAck1_3 );
        method enWrite1_3() enable( writeAck1_3 );
        `endif

        method readData1_4(readReq_data1_4) enable( readAck1_4 );
        method enWrite1_4() enable( writeAck1_4 );

        
        `ifndef REDUCE_PAR_TO_2
        method readData2_0(readReq_data2_0) enable( readAck2_0 );
        method enWrite2_0() enable( writeAck2_0 );

        method readData2_1(readReq_data2_1) enable( readAck2_1 );
        method enWrite2_1() enable( writeAck2_1 );

        method readData2_2(readReq_data2_2) enable( readAck2_2 );
        method enWrite2_2() enable( writeAck2_2 );

        `ifndef CENTRE_BUFFER_ONCHIP
        method readData2_3(readReq_data2_3) enable( readAck2_3 );
        method enWrite2_3() enable( writeAck2_3 );
        `endif

        method readData2_4(readReq_data2_4) enable( readAck2_4 );
        method enWrite2_4() enable( writeAck2_4 );


        method readData3_0(readReq_data3_0) enable( readAck3_0 );
        method enWrite3_0() enable( writeAck3_0 );

        method readData3_1(readReq_data3_1) enable( readAck3_1 );
        method enWrite3_1() enable( writeAck3_1 );

        method readData3_2(readReq_data3_2) enable( readAck3_2 );
        method enWrite3_2() enable( writeAck3_2 );

        `ifndef CENTRE_BUFFER_ONCHIP
        method readData3_3(readReq_data3_3) enable( readAck3_3 );
        method enWrite3_3() enable( writeAck3_3 );
        `endif

        method readData3_4(readReq_data3_4) enable( readAck3_4 );
        method enWrite3_4() enable( writeAck3_4 );

        `endif
        `endif
        
        // outputs
        
        method writeReq_data0_0 writeData0_0() ready(writeReq0_0);
        method writeReq_addr0_0 writeAddr0_0() ready(writeReq0_0);
        method readReq_addr0_0 readRequest0_0() ready(readReq0_0);

        method writeReq_data0_1 writeData0_1() ready(writeReq0_1);
        method writeReq_addr0_1 writeAddr0_1() ready(writeReq0_1);
        method readReq_addr0_1 readRequest0_1() ready(readReq0_1);

        method writeReq_data0_2 writeData0_2() ready(writeReq0_2);
        method writeReq_addr0_2 writeAddr0_2() ready(writeReq0_2);
        method readReq_addr0_2 readRequest0_2() ready(readReq0_2);

        `ifndef CENTRE_BUFFER_ONCHIP
        method writeReq_data0_3 writeData0_3() ready(writeReq0_3);
        method writeReq_addr0_3 writeAddr0_3() ready(writeReq0_3);
        method readReq_addr0_3 readRequest0_3() ready(readReq0_3);
        method access_critical_region0 accessCriticalRegion0() ready(access_critical_region0_ap_vld);
        `endif

        method writeReq_data0_4 writeData0_4() ready(writeReq0_4);
        method writeReq_addr0_4 writeAddr0_4() ready(writeReq0_4);
        method readReq_addr0_4 readRequest0_4() ready(readReq0_4);


        `ifndef REDUCE_PAR_TO_1
        method writeReq_data1_0 writeData1_0() ready(writeReq1_0);
        method writeReq_addr1_0 writeAddr1_0() ready(writeReq1_0);
        method readReq_addr1_0 readRequest1_0() ready(readReq1_0);

        method writeReq_data1_1 writeData1_1() ready(writeReq1_1);
        method writeReq_addr1_1 writeAddr1_1() ready(writeReq1_1);
        method readReq_addr1_1 readRequest1_1() ready(readReq1_1);

        method writeReq_data1_2 writeData1_2() ready(writeReq1_2);
        method writeReq_addr1_2 writeAddr1_2() ready(writeReq1_2);
        method readReq_addr1_2 readRequest1_2() ready(readReq1_2);

        `ifndef CENTRE_BUFFER_ONCHIP
        method writeReq_data1_3 writeData1_3() ready(writeReq1_3);
        method writeReq_addr1_3 writeAddr1_3() ready(writeReq1_3);
        method readReq_addr1_3 readRequest1_3() ready(readReq1_3);
        method access_critical_region1 accessCriticalRegion1() ready(access_critical_region1_ap_vld);
        `endif

        method writeReq_data1_4 writeData1_4() ready(writeReq1_4);
        method writeReq_addr1_4 writeAddr1_4() ready(writeReq1_4);
        method readReq_addr1_4 readRequest1_4() ready(readReq1_4);


        `ifndef REDUCE_PAR_TO_2
        method writeReq_data2_0 writeData2_0() ready(writeReq2_0);
        method writeReq_addr2_0 writeAddr2_0() ready(writeReq2_0);
        method readReq_addr2_0 readRequest2_0() ready(readReq2_0);

        method writeReq_data2_1 writeData2_1() ready(writeReq2_1);
        method writeReq_addr2_1 writeAddr2_1() ready(writeReq2_1);
        method readReq_addr2_1 readRequest2_1() ready(readReq2_1);

        method writeReq_data2_2 writeData2_2() ready(writeReq2_2);
        method writeReq_addr2_2 writeAddr2_2() ready(writeReq2_2);
        method readReq_addr2_2 readRequest2_2() ready(readReq2_2);

        `ifndef CENTRE_BUFFER_ONCHIP
        method writeReq_data2_3 writeData2_3() ready(writeReq2_3);
        method writeReq_addr2_3 writeAddr2_3() ready(writeReq2_3);
        method readReq_addr2_3 readRequest2_3() ready(readReq2_3);
        method access_critical_region2 accessCriticalRegion2() ready(access_critical_region2_ap_vld);
        `endif

        method writeReq_data2_4 writeData2_4() ready(writeReq2_4);
        method writeReq_addr2_4 writeAddr2_4() ready(writeReq2_4);
        method readReq_addr2_4 readRequest2_4() ready(readReq2_4);


        method writeReq_data3_0 writeData3_0() ready(writeReq3_0);
        method writeReq_addr3_0 writeAddr3_0() ready(writeReq3_0);
        method readReq_addr3_0 readRequest3_0() ready(readReq3_0);

        method writeReq_data3_1 writeData3_1() ready(writeReq3_1);
        method writeReq_addr3_1 writeAddr3_1() ready(writeReq3_1);
        method readReq_addr3_1 readRequest3_1() ready(readReq3_1);

        method writeReq_data3_2 writeData3_2() ready(writeReq3_2);
        method writeReq_addr3_2 writeAddr3_2() ready(writeReq3_2);
        method readReq_addr3_2 readRequest3_2() ready(readReq3_2);

        `ifndef CENTRE_BUFFER_ONCHIP
        method writeReq_data3_3 writeData3_3() ready(writeReq3_3);
        method writeReq_addr3_3 writeAddr3_3() ready(writeReq3_3);
        method readReq_addr3_3 readRequest3_3() ready(readReq3_3);
        method access_critical_region3 accessCriticalRegion3() ready(access_critical_region3_ap_vld);
        `endif

        method writeReq_data3_4 writeData3_4() ready(writeReq3_4);
        method writeReq_addr3_4 writeAddr3_4() ready(writeReq3_4);
        method readReq_addr3_4 readRequest3_4() ready(readReq3_4);

        `endif
        `endif


        // tell the compiler all the combinational paths from input to output
        //... not now ...

        // scheduling
        schedule (   
            start, 
            setN, 
            setK,
            setL,
            ipReady,
            ipIdle,
            ipDone,
            i_node_data,
            en_i_node_data,
            root,
            en_root,
            cntr_pos_init,
            en_cntr_pos_init,
            en_clusters_out,
            en_distortion_out,            

            readData0_0,
            enWrite0_0,
            readData0_1,
            enWrite0_1,
            readData0_2,
            enWrite0_2,
            `ifndef CENTRE_BUFFER_ONCHIP
            readData0_3,
            enWrite0_3,
            `endif
            readData0_4,
            enWrite0_4,
            writeData0_0,
            writeAddr0_0,
            readRequest0_0,
            writeData0_1,
            writeAddr0_1,
            readRequest0_1,
            writeData0_2,
            writeAddr0_2,
            readRequest0_2,
            `ifndef CENTRE_BUFFER_ONCHIP
            writeData0_3,
            writeAddr0_3,
            readRequest0_3,
            accessCriticalRegion0,
            `endif
            writeData0_4,
            writeAddr0_4,
            readRequest0_4,

            `ifndef REDUCE_PAR_TO_1
            readData1_0,
            enWrite1_0,
            readData1_1,
            enWrite1_1,
            readData1_2,
            enWrite1_2,
            `ifndef CENTRE_BUFFER_ONCHIP
            readData1_3,
            enWrite1_3,
            `endif
            readData1_4,
            enWrite1_4,
            writeData1_0,
            writeAddr1_0,
            readRequest1_0,
            writeData1_1,
            writeAddr1_1,
            readRequest1_1,
            writeData1_2,
            writeAddr1_2,
            readRequest1_2,
            `ifndef CENTRE_BUFFER_ONCHIP
            writeData1_3,
            writeAddr1_3,
            readRequest1_3,
            accessCriticalRegion1,
            `endif
            writeData1_4,
            writeAddr1_4,
            readRequest1_4,

            `ifndef REDUCE_PAR_TO_2
            readData2_0,
            enWrite2_0,
            readData2_1,
            enWrite2_1,
            readData2_2,
            enWrite2_2,
            `ifndef CENTRE_BUFFER_ONCHIP
            readData2_3,
            enWrite2_3,
            `endif
            readData2_4,
            enWrite2_4,
            writeData2_0,
            writeAddr2_0,
            readRequest2_0,
            writeData2_1,
            writeAddr2_1,
            readRequest2_1,
            writeData2_2,
            writeAddr2_2,
            readRequest2_2,
            `ifndef CENTRE_BUFFER_ONCHIP
            writeData2_3,
            writeAddr2_3,
            readRequest2_3,
            accessCriticalRegion2,
            `endif
            writeData2_4,
            writeAddr2_4,
            readRequest2_4,

            readData3_0,
            enWrite3_0,
            readData3_1,
            enWrite3_1,
            readData3_2,
            enWrite3_2,
            `ifndef CENTRE_BUFFER_ONCHIP
            readData3_3,
            enWrite3_3,
            `endif
            readData3_4,
            enWrite3_4,
            writeData3_0,
            writeAddr3_0,
            readRequest3_0,
            writeData3_1,
            writeAddr3_1,
            readRequest3_1,
            writeData3_2,
            writeAddr3_2,
            readRequest3_2,
            `ifndef CENTRE_BUFFER_ONCHIP
            writeData3_3,
            writeAddr3_3,
            readRequest3_3,
            accessCriticalRegion3,
            `endif
            writeData3_4,
            writeAddr3_4,
            readRequest3_4,

            `endif
            `endif

            clusters_out,
            distortion_out
            
        ) 
        CF 
        (   
            start, 
            setN, 
            setK,
            setL,
            ipReady,
            ipIdle,
            ipDone,
            i_node_data,
            en_i_node_data,
            root,
            en_root,
            cntr_pos_init,
            en_cntr_pos_init,
            en_clusters_out,
            en_distortion_out,            

            readData0_0,
            enWrite0_0,
            readData0_1,
            enWrite0_1,
            readData0_2,
            enWrite0_2,
            `ifndef CENTRE_BUFFER_ONCHIP
            readData0_3,
            enWrite0_3,
            `endif
            readData0_4,
            enWrite0_4,
            writeData0_0,
            writeAddr0_0,
            readRequest0_0,
            writeData0_1,
            writeAddr0_1,
            readRequest0_1,
            writeData0_2,
            writeAddr0_2,
            readRequest0_2,
            `ifndef CENTRE_BUFFER_ONCHIP
            writeData0_3,
            writeAddr0_3,
            readRequest0_3,
            accessCriticalRegion0,
            `endif
            writeData0_4,
            writeAddr0_4,
            readRequest0_4,

            `ifndef REDUCE_PAR_TO_1
            readData1_0,
            enWrite1_0,
            readData1_1,
            enWrite1_1,
            readData1_2,
            enWrite1_2,
            `ifndef CENTRE_BUFFER_ONCHIP
            readData1_3,
            enWrite1_3,
            `endif
            readData1_4,
            enWrite1_4,
            writeData1_0,
            writeAddr1_0,
            readRequest1_0,
            writeData1_1,
            writeAddr1_1,
            readRequest1_1,
            writeData1_2,
            writeAddr1_2,
            readRequest1_2,
            `ifndef CENTRE_BUFFER_ONCHIP
            writeData1_3,
            writeAddr1_3,
            readRequest1_3,
            accessCriticalRegion1,
            `endif
            writeData1_4,
            writeAddr1_4,
            readRequest1_4,

            `ifndef REDUCE_PAR_TO_2
            readData2_0,
            enWrite2_0,
            readData2_1,
            enWrite2_1,
            readData2_2,
            enWrite2_2,
            `ifndef CENTRE_BUFFER_ONCHIP
            readData2_3,
            enWrite2_3,
            `endif
            readData2_4,
            enWrite2_4,
            writeData2_0,
            writeAddr2_0,
            readRequest2_0,
            writeData2_1,
            writeAddr2_1,
            readRequest2_1,
            writeData2_2,
            writeAddr2_2,
            readRequest2_2,
            `ifndef CENTRE_BUFFER_ONCHIP
            writeData2_3,
            writeAddr2_3,
            readRequest2_3,
            accessCriticalRegion2,
            `endif
            writeData2_4,
            writeAddr2_4,
            readRequest2_4,

            readData3_0,
            enWrite3_0,
            readData3_1,
            enWrite3_1,
            readData3_2,
            enWrite3_2,
            `ifndef CENTRE_BUFFER_ONCHIP
            readData3_3,
            enWrite3_3,
            `endif
            readData3_4,
            enWrite3_4,
            writeData3_0,
            writeAddr3_0,
            readRequest3_0,
            writeData3_1,
            writeAddr3_1,
            readRequest3_1,
            writeData3_2,
            writeAddr3_2,
            readRequest3_2,
            `ifndef CENTRE_BUFFER_ONCHIP
            writeData3_3,
            writeAddr3_3,
            readRequest3_3,
            accessCriticalRegion3,
            `endif
            writeData3_4,
            writeAddr3_4,
            readRequest3_4,

            `endif
            `endif

            clusters_out,
            distortion_out

        );




   endmodule
