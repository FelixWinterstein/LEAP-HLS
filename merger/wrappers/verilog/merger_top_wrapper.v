/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: filtering_algorithm_top_wrapper.v
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/


// wrapper for the HLS core and bus bridge

//`define REDUCE_PAR_TO_1


module merger_top_wrapper (
    input   ap_clk,
    input   ap_rst_n,
    input   ap_start,
    output   ap_done,
    output   ap_idle,
    output   ap_ready,
    input  [31:0] n,

    output writeReq0,
    output [63:0] writeReq_data0,
    output [31:0] writeReq_addr0,
    input writeAck0,
    output readReq0,
    output [31:0] readReq_addr0,
    input readAck0,
    input [63:0] readReq_data0,

    output writeReq4,
    output [31:0] writeReq_data4,
    output [31:0] writeReq_addr4,
    input writeAck4,
    output readReq4,
    output [31:0] readReq_addr4,
    input readAck4,
    input [31:0] readReq_data4,

    `ifndef REDUCE_PAR_TO_1

    output writeReq1,    
    output [63:0] writeReq_data1,
    output [31:0] writeReq_addr1,
    input writeAck1,
    output readReq1,
    output [31:0] readReq_addr1,
    input readAck1,
    input [63:0] readReq_data1,

    output writeReq2,
    output [63:0] writeReq_data2,
    output [31:0] writeReq_addr2,
    input writeAck2,
    output readReq2,
    output [31:0] readReq_addr2,
    input readAck2,
    input [63:0] readReq_data2,

    output writeReq3,
    output [63:0] writeReq_data3,
    output [31:0] writeReq_addr3,
    input writeAck3,
    output readReq3,
    output [31:0] readReq_addr3,
    input readAck3,
    input [63:0] readReq_data3,  

    output writeReq5,    
    output [31:0] writeReq_data5,
    output [31:0] writeReq_addr5,
    input writeAck5,
    output readReq5,
    output [31:0] readReq_addr5,
    input readAck5,
    input [31:0] readReq_data5,

    output writeReq6,
    output [31:0] writeReq_data6,
    output [31:0] writeReq_addr6,
    input writeAck6,
    output readReq6,
    output [31:0] readReq_addr6,
    input readAck6,
    input [31:0] readReq_data6,

    output writeReq7,
    output [31:0] writeReq_data7,
    output [31:0] writeReq_addr7,
    input writeAck7,
    output readReq7,
    output [31:0] readReq_addr7,
    input readAck7,
    input [31:0] readReq_data7, 

    `endif
    input  [31:0] val_r1_dout,
    input   val_r1_empty_n,
    output   val_r1_read,
    input  [31:0] val_r2_dout,
    input   val_r2_empty_n,
    output   val_r2_read,
    input  [31:0] val_r3_dout,
    input   val_r3_empty_n,
    output   val_r3_read,
    input  [31:0] val_r4_dout,
    input   val_r4_empty_n,
    output   val_r4_read,
    output  [31:0] val_w_din,
    input   val_w_full_n,
    output   val_w_write
);

    wire   data_bus_0_req_din;
    wire   data_bus_0_req_full_n;
    wire   data_bus_0_req_write;
    wire   data_bus_0_rsp_empty_n;
    wire   data_bus_0_rsp_read;
    wire  [31:0] data_bus_0_address;
    wire  [63:0] data_bus_0_datain;
    wire  [63:0] data_bus_0_dataout;
    wire  [31:0] data_bus_0_size;

    wire   data_bus_1_req_din;
    wire   data_bus_1_req_full_n;
    wire   data_bus_1_req_write;
    wire   data_bus_1_rsp_empty_n;
    wire   data_bus_1_rsp_read;
    wire  [31:0] data_bus_1_address;
    wire  [63:0] data_bus_1_datain;
    wire  [63:0] data_bus_1_dataout;
    wire  [31:0] data_bus_1_size;

    wire   data_bus_2_req_din;
    wire   data_bus_2_req_full_n;
    wire   data_bus_2_req_write;
    wire   data_bus_2_rsp_empty_n;
    wire   data_bus_2_rsp_read;
    wire  [31:0] data_bus_2_address;
    wire  [63:0] data_bus_2_datain;
    wire  [63:0] data_bus_2_dataout;
    wire  [31:0] data_bus_2_size;

    wire   data_bus_3_req_din;
    wire   data_bus_3_req_full_n;
    wire   data_bus_3_req_write;
    wire   data_bus_3_rsp_empty_n;
    wire   data_bus_3_rsp_read;
    wire  [31:0] data_bus_3_address;
    wire  [63:0] data_bus_3_datain;
    wire  [63:0] data_bus_3_dataout;
    wire  [31:0] data_bus_3_size;


    wire   freelist_bus_0_req_din;
    wire   freelist_bus_0_req_full_n;
    wire   freelist_bus_0_req_write;
    wire   freelist_bus_0_rsp_empty_n;
    wire   freelist_bus_0_rsp_read;
    wire  [31:0] freelist_bus_0_address;
    wire  [31:0] freelist_bus_0_datain;
    wire  [31:0] freelist_bus_0_dataout;
    wire  [31:0] freelist_bus_0_size;

    wire   freelist_bus_1_req_din;
    wire   freelist_bus_1_req_full_n;
    wire   freelist_bus_1_req_write;
    wire   freelist_bus_1_rsp_empty_n;
    wire   freelist_bus_1_rsp_read;
    wire  [31:0] freelist_bus_1_address;
    wire  [31:0] freelist_bus_1_datain;
    wire  [31:0] freelist_bus_1_dataout;
    wire  [31:0] freelist_bus_1_size;

    wire   freelist_bus_2_req_din;
    wire   freelist_bus_2_req_full_n;
    wire   freelist_bus_2_req_write;
    wire   freelist_bus_2_rsp_empty_n;
    wire   freelist_bus_2_rsp_read;
    wire  [31:0] freelist_bus_2_address;
    wire  [31:0] freelist_bus_2_datain;
    wire  [31:0] freelist_bus_2_dataout;
    wire  [31:0] freelist_bus_2_size;

    wire   freelist_bus_3_req_din;
    wire   freelist_bus_3_req_full_n;
    wire   freelist_bus_3_req_write;
    wire   freelist_bus_3_rsp_empty_n;
    wire   freelist_bus_3_rsp_read;
    wire  [31:0] freelist_bus_3_address;
    wire  [31:0] freelist_bus_3_datain;
    wire  [31:0] freelist_bus_3_dataout;
    wire  [31:0] freelist_bus_3_size;



    merger_top merger_top_U (
        .ap_clk (ap_clk),
        .ap_rst_n (ap_rst_n),
        .ap_start (ap_start),
        .ap_done (ap_done),
        .ap_idle (ap_idle),
        .ap_ready (ap_ready),
        .n (n),
        .data_bus_1_req_din (data_bus_0_req_din),
        .data_bus_1_req_full_n (data_bus_0_req_full_n),
        .data_bus_1_req_write (data_bus_0_req_write),
        .data_bus_1_rsp_empty_n (data_bus_0_rsp_empty_n),
        .data_bus_1_rsp_read (data_bus_0_rsp_read),
        .data_bus_1_address (data_bus_0_address),
        .data_bus_1_datain (data_bus_0_datain),
        .data_bus_1_dataout (data_bus_0_dataout),
        .data_bus_1_size (data_bus_0_size),
        .freelist_bus_1_req_din (freelist_bus_0_req_din),
        .freelist_bus_1_req_full_n (freelist_bus_0_req_full_n),
        .freelist_bus_1_req_write (freelist_bus_0_req_write),
        .freelist_bus_1_rsp_empty_n (freelist_bus_0_rsp_empty_n),
        .freelist_bus_1_rsp_read (freelist_bus_0_rsp_read),
        .freelist_bus_1_address (freelist_bus_0_address),
        .freelist_bus_1_datain (freelist_bus_0_datain),
        .freelist_bus_1_dataout (freelist_bus_0_dataout),
        .freelist_bus_1_size (freelist_bus_0_size),
        `ifndef REDUCE_PAR_TO_1
        .data_bus_2_req_din (data_bus_1_req_din),
        .data_bus_2_req_full_n (data_bus_1_req_full_n),
        .data_bus_2_req_write (data_bus_1_req_write),
        .data_bus_2_rsp_empty_n (data_bus_1_rsp_empty_n),
        .data_bus_2_rsp_read (data_bus_1_rsp_read),
        .data_bus_2_address (data_bus_1_address),
        .data_bus_2_datain (data_bus_1_datain),
        .data_bus_2_dataout (data_bus_1_dataout),
        .data_bus_2_size (data_bus_1_size),
        .data_bus_3_req_din (data_bus_2_req_din),
        .data_bus_3_req_full_n (data_bus_2_req_full_n),
        .data_bus_3_req_write (data_bus_2_req_write),
        .data_bus_3_rsp_empty_n (data_bus_2_rsp_empty_n),
        .data_bus_3_rsp_read (data_bus_2_rsp_read),
        .data_bus_3_address (data_bus_2_address),
        .data_bus_3_datain (data_bus_2_datain),
        .data_bus_3_dataout (data_bus_2_dataout),
        .data_bus_3_size (data_bus_2_size),
        .data_bus_4_req_din (data_bus_3_req_din),
        .data_bus_4_req_full_n (data_bus_3_req_full_n),
        .data_bus_4_req_write (data_bus_3_req_write),
        .data_bus_4_rsp_empty_n (data_bus_3_rsp_empty_n),
        .data_bus_4_rsp_read (data_bus_3_rsp_read),
        .data_bus_4_address (data_bus_3_address),
        .data_bus_4_datain (data_bus_3_datain),
        .data_bus_4_dataout (data_bus_3_dataout),
        .data_bus_4_size (data_bus_3_size),
        .freelist_bus_2_req_din (freelist_bus_1_req_din),
        .freelist_bus_2_req_full_n (freelist_bus_1_req_full_n),
        .freelist_bus_2_req_write (freelist_bus_1_req_write),
        .freelist_bus_2_rsp_empty_n (freelist_bus_1_rsp_empty_n),
        .freelist_bus_2_rsp_read (freelist_bus_1_rsp_read),
        .freelist_bus_2_address (freelist_bus_1_address),
        .freelist_bus_2_datain (freelist_bus_1_datain),
        .freelist_bus_2_dataout (freelist_bus_1_dataout),
        .freelist_bus_2_size (freelist_bus_1_size),
        .freelist_bus_3_req_din (freelist_bus_2_req_din),
        .freelist_bus_3_req_full_n (freelist_bus_2_req_full_n),
        .freelist_bus_3_req_write (freelist_bus_2_req_write),
        .freelist_bus_3_rsp_empty_n (freelist_bus_2_rsp_empty_n),
        .freelist_bus_3_rsp_read (freelist_bus_2_rsp_read),
        .freelist_bus_3_address (freelist_bus_2_address),
        .freelist_bus_3_datain (freelist_bus_2_datain),
        .freelist_bus_3_dataout (freelist_bus_2_dataout),
        .freelist_bus_3_size (freelist_bus_2_size),
        .freelist_bus_4_req_din (freelist_bus_3_req_din),
        .freelist_bus_4_req_full_n (freelist_bus_3_req_full_n),
        .freelist_bus_4_req_write (freelist_bus_3_req_write),
        .freelist_bus_4_rsp_empty_n (freelist_bus_3_rsp_empty_n),
        .freelist_bus_4_rsp_read (freelist_bus_3_rsp_read),
        .freelist_bus_4_address (freelist_bus_3_address),
        .freelist_bus_4_datain (freelist_bus_3_datain),
        .freelist_bus_4_dataout (freelist_bus_3_dataout),
        .freelist_bus_4_size (freelist_bus_3_size),
        `endif
        .val_r1_dout (val_r1_dout),
        .val_r1_empty_n (val_r1_empty_n),
        .val_r1_read (val_r1_read),
        .val_r2_dout (val_r2_dout),
        .val_r2_empty_n (val_r2_empty_n),
        .val_r2_read (val_r2_read),
        .val_r3_dout (val_r3_dout),
        .val_r3_empty_n (val_r3_empty_n),
        .val_r3_read (val_r3_read),
        .val_r4_dout (val_r4_dout),
        .val_r4_empty_n (val_r4_empty_n),
        .val_r4_read (val_r4_read),
        .val_w_din (val_w_din),
        .val_w_full_n (val_w_full_n),
        .val_w_write (val_w_write)
    );


    bus_bridge #(
         .DATA_WIDTH ( 64 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U0 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (data_bus_0_rsp_empty_n),    
        .rsp_full_n (data_bus_0_req_full_n),
        .req_write (data_bus_0_req_write),
        .req_din (data_bus_0_req_din),
        .rsp_read (data_bus_0_rsp_read),
        .address (data_bus_0_address),
        .size (data_bus_0_size),
        .dataout (data_bus_0_dataout),
        .datain (data_bus_0_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq0),
        .writeReq_data (writeReq_data0),
        .writeReq_addr (writeReq_addr0),
        .writeAck (writeAck0),
        .readReq (readReq0),
        .readReq_addr (readReq_addr0),
        .readAck (readAck0),
        .readReq_data (readReq_data0)
    );


    bus_bridge #(
         .DATA_WIDTH ( 32 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U0_1 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (freelist_bus_0_rsp_empty_n),    
        .rsp_full_n (freelist_bus_0_req_full_n),
        .req_write (freelist_bus_0_req_write),
        .req_din (freelist_bus_0_req_din),
        .rsp_read (freelist_bus_0_rsp_read),
        .address (freelist_bus_0_address),
        .size (freelist_bus_0_size),
        .dataout (freelist_bus_0_dataout),
        .datain (freelist_bus_0_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq4),
        .writeReq_data (writeReq_data4),
        .writeReq_addr (writeReq_addr4),
        .writeAck (writeAck4),
        .readReq (readReq4),
        .readReq_addr (readReq_addr4),
        .readAck (readAck4),
        .readReq_data (readReq_data4)
    );


    `ifndef REDUCE_PAR_TO_1

    bus_bridge #(
         .DATA_WIDTH ( 64 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U1 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (data_bus_1_rsp_empty_n),    
        .rsp_full_n (data_bus_1_req_full_n),
        .req_write (data_bus_1_req_write),
        .req_din (data_bus_1_req_din),
        .rsp_read (data_bus_1_rsp_read),
        .address (data_bus_1_address),
        .size (data_bus_1_size),
        .dataout (data_bus_1_dataout),
        .datain (data_bus_1_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq1),
        .writeReq_data (writeReq_data1),
        .writeReq_addr (writeReq_addr1),
        .writeAck (writeAck1),
        .readReq (readReq1),
        .readReq_addr (readReq_addr1),
        .readAck (readAck1),
        .readReq_data (readReq_data1)
    );


    bus_bridge #(
         .DATA_WIDTH ( 64 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U2 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (data_bus_2_rsp_empty_n),    
        .rsp_full_n (data_bus_2_req_full_n),
        .req_write (data_bus_2_req_write),
        .req_din (data_bus_2_req_din),
        .rsp_read (data_bus_2_rsp_read),
        .address (data_bus_2_address),
        .size (data_bus_2_size),
        .dataout (data_bus_2_dataout),
        .datain (data_bus_2_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq2),
        .writeReq_data (writeReq_data2),
        .writeReq_addr (writeReq_addr2),
        .writeAck (writeAck2),
        .readReq (readReq2),
        .readReq_addr (readReq_addr2),
        .readAck (readAck2),
        .readReq_data (readReq_data2)
    );


    bus_bridge #(
         .DATA_WIDTH ( 64 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U3 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (data_bus_3_rsp_empty_n),    
        .rsp_full_n (data_bus_3_req_full_n),
        .req_write (data_bus_3_req_write),
        .req_din (data_bus_3_req_din),
        .rsp_read (data_bus_3_rsp_read),
        .address (data_bus_3_address),
        .size (data_bus_3_size),
        .dataout (data_bus_3_dataout),
        .datain (data_bus_3_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq3),
        .writeReq_data (writeReq_data3),
        .writeReq_addr (writeReq_addr3),
        .writeAck (writeAck3),
        .readReq (readReq3),
        .readReq_addr (readReq_addr3),
        .readAck (readAck3),
        .readReq_data (readReq_data3)
    );


    bus_bridge #(
         .DATA_WIDTH ( 32 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U1_1 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (freelist_bus_1_rsp_empty_n),    
        .rsp_full_n (freelist_bus_1_req_full_n),
        .req_write (freelist_bus_1_req_write),
        .req_din (freelist_bus_1_req_din),
        .rsp_read (freelist_bus_1_rsp_read),
        .address (freelist_bus_1_address),
        .size (freelist_bus_1_size),
        .dataout (freelist_bus_1_dataout),
        .datain (freelist_bus_1_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq5),
        .writeReq_data (writeReq_data5),
        .writeReq_addr (writeReq_addr5),
        .writeAck (writeAck5),
        .readReq (readReq5),
        .readReq_addr (readReq_addr5),
        .readAck (readAck5),
        .readReq_data (readReq_data5)
    );


    bus_bridge #(
         .DATA_WIDTH ( 32 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U2_1 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (freelist_bus_2_rsp_empty_n),    
        .rsp_full_n (freelist_bus_2_req_full_n),
        .req_write (freelist_bus_2_req_write),
        .req_din (freelist_bus_2_req_din),
        .rsp_read (freelist_bus_2_rsp_read),
        .address (freelist_bus_2_address),
        .size (freelist_bus_2_size),
        .dataout (freelist_bus_2_dataout),
        .datain (freelist_bus_2_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq6),
        .writeReq_data (writeReq_data6),
        .writeReq_addr (writeReq_addr6),
        .writeAck (writeAck6),
        .readReq (readReq6),
        .readReq_addr (readReq_addr6),
        .readAck (readAck6),
        .readReq_data (readReq_data6)
    );


    bus_bridge #(
         .DATA_WIDTH ( 32 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U3_1 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (freelist_bus_3_rsp_empty_n),    
        .rsp_full_n (freelist_bus_3_req_full_n),
        .req_write (freelist_bus_3_req_write),
        .req_din (freelist_bus_3_req_din),
        .rsp_read (freelist_bus_3_rsp_read),
        .address (freelist_bus_3_address),
        .size (freelist_bus_3_size),
        .dataout (freelist_bus_3_dataout),
        .datain (freelist_bus_3_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq7),
        .writeReq_data (writeReq_data7),
        .writeReq_addr (writeReq_addr7),
        .writeAck (writeAck7),
        .readReq (readReq7),
        .readReq_addr (readReq_addr7),
        .readAck (readAck7),
        .readReq_data (readReq_data7)
    );



    `endif

endmodule
