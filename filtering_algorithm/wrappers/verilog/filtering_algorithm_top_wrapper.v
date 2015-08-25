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
//`define REDUCE_PAR_TO_2
//`define CENTRE_BUFFER_ONCHIP

module filtering_algorithm_top_wrapper (
    input   ap_clk,
    input   ap_rst_n,
    input   ap_start,
    output   ap_done,
    output   ap_idle,
    output   ap_ready,
    input  [399:0] i_node_data_value_V_dout,
    input   i_node_data_value_V_empty_n,
    output   i_node_data_value_V_read,

    output writeReq0_0,
    output [511:0] writeReq_data0_0,
    output [31:0] writeReq_addr0_0,
    input writeAck0_0,
    output readReq0_0,
    output [31:0] readReq_addr0_0,
    input readAck0_0,
    input [511:0] readReq_data0_0,

    output writeReq0_1,
    output [7:0] writeReq_data0_1,
    output [31:0] writeReq_addr0_1,
    input writeAck0_1,
    output readReq0_1,
    output [31:0] readReq_addr0_1,
    input readAck0_1,
    input [7:0] readReq_data0_1,

    output writeReq0_2,
    output [95:0] writeReq_data0_2,
    output [31:0] writeReq_addr0_2,
    input writeAck0_2,
    output readReq0_2,
    output [31:0] readReq_addr0_2,
    input readAck0_2,
    input [95:0] readReq_data0_2,

    `ifndef CENTRE_BUFFER_ONCHIP
    output writeReq0_3,
    output [63:0] writeReq_data0_3,
    output [31:0] writeReq_addr0_3,
    input writeAck0_3,
    output readReq0_3,
    output [31:0] readReq_addr0_3,
    input readAck0_3,
    input [63:0] readReq_data0_3,
    output access_critical_region0,
    output access_critical_region0_ap_vld,
    `endif

    output writeReq0_4,
    output [31:0] writeReq_data0_4,
    output [31:0] writeReq_addr0_4,
    input writeAck0_4,
    output readReq0_4,
    output [31:0] readReq_addr0_4,
    input readAck0_4,
    input [31:0] readReq_data0_4,

    `ifndef REDUCE_PAR_TO_1
    output writeReq1_0,
    output [511:0] writeReq_data1_0,
    output [31:0] writeReq_addr1_0,
    input writeAck1_0,
    output readReq1_0,
    output [31:0] readReq_addr1_0,
    input readAck1_0,
    input [511:0] readReq_data1_0,

    output writeReq1_1,
    output [7:0] writeReq_data1_1,
    output [31:0] writeReq_addr1_1,
    input writeAck1_1,
    output readReq1_1,
    output [31:0] readReq_addr1_1,
    input readAck1_1,
    input [7:0] readReq_data1_1,

    output writeReq1_2,
    output [95:0] writeReq_data1_2,
    output [31:0] writeReq_addr1_2,
    input writeAck1_2,
    output readReq1_2,
    output [31:0] readReq_addr1_2,
    input readAck1_2,
    input [95:0] readReq_data1_2,

    `ifndef CENTRE_BUFFER_ONCHIP
    output writeReq1_3,
    output [63:0] writeReq_data1_3,
    output [31:0] writeReq_addr1_3,
    input writeAck1_3,
    output readReq1_3,
    output [31:0] readReq_addr1_3,
    input readAck1_3,
    input [63:0] readReq_data1_3,
    output access_critical_region1,
    output access_critical_region1_ap_vld,
    `endif

    output writeReq1_4,
    output [31:0] writeReq_data1_4,
    output [31:0] writeReq_addr1_4,
    input writeAck1_4,
    output readReq1_4,
    output [31:0] readReq_addr1_4,
    input readAck1_4,
    input [31:0] readReq_data1_4,

    `ifndef REDUCE_PAR_TO_2
    output writeReq2_0,
    output [511:0] writeReq_data2_0,
    output [31:0] writeReq_addr2_0,
    input writeAck2_0,
    output readReq2_0,
    output [31:0] readReq_addr2_0,
    input readAck2_0,
    input [511:0] readReq_data2_0,

    output writeReq2_1,
    output [7:0] writeReq_data2_1,
    output [31:0] writeReq_addr2_1,
    input writeAck2_1,
    output readReq2_1,
    output [31:0] readReq_addr2_1,
    input readAck2_1,
    input [7:0] readReq_data2_1,

    output writeReq2_2,
    output [95:0] writeReq_data2_2,
    output [31:0] writeReq_addr2_2,
    input writeAck2_2,
    output readReq2_2,
    output [31:0] readReq_addr2_2,
    input readAck2_2,
    input [95:0] readReq_data2_2,

    `ifndef CENTRE_BUFFER_ONCHIP
    output writeReq2_3,
    output [63:0] writeReq_data2_3,
    output [31:0] writeReq_addr2_3,
    input writeAck2_3,
    output readReq2_3,
    output [31:0] readReq_addr2_3,
    input readAck2_3,
    input [63:0] readReq_data2_3,
    output access_critical_region2,
    output access_critical_region2_ap_vld,
    `endif

    output writeReq2_4,
    output [31:0] writeReq_data2_4,
    output [31:0] writeReq_addr2_4,
    input writeAck2_4,
    output readReq2_4,
    output [31:0] readReq_addr2_4,
    input readAck2_4,
    input [31:0] readReq_data2_4,

    output writeReq3_0,
    output [511:0] writeReq_data3_0,
    output [31:0] writeReq_addr3_0,
    input writeAck3_0,
    output readReq3_0,
    output [31:0] readReq_addr3_0,
    input readAck3_0,
    input [511:0] readReq_data3_0,

    output writeReq3_1,
    output [7:0] writeReq_data3_1,
    output [31:0] writeReq_addr3_1,
    input writeAck3_1,
    output readReq3_1,
    output [31:0] readReq_addr3_1,
    input readAck3_1,
    input [7:0] readReq_data3_1,

    output writeReq3_2,
    output [95:0] writeReq_data3_2,
    output [31:0] writeReq_addr3_2,
    input writeAck3_2,
    output readReq3_2,
    output [31:0] readReq_addr3_2,
    input readAck3_2,
    input [95:0] readReq_data3_2,

    `ifndef CENTRE_BUFFER_ONCHIP
    output writeReq3_3,
    output [63:0] writeReq_data3_3,
    output [31:0] writeReq_addr3_3,
    input writeAck3_3,
    output readReq3_3,
    output [31:0] readReq_addr3_3,
    input readAck3_3,
    input [63:0] readReq_data3_3,
    output access_critical_region3,
    output access_critical_region3_ap_vld,
    `endif

    output writeReq3_4,
    output [31:0] writeReq_data3_4,
    output [31:0] writeReq_addr3_4,
    input writeAck3_4,
    output readReq3_4,
    output [31:0] readReq_addr3_4,
    input readAck3_4,
    input [31:0] readReq_data3_4,

    `endif
    `endif

    input  [47:0] cntr_pos_init_value_V_dout,
    input   cntr_pos_init_value_V_empty_n,
    output   cntr_pos_init_value_V_read,
    input  [31:0] n_V,
    input  [7:0] k_V,
    input  [31:0] l,
    input  [31:0] root_V_dout,
    input   root_V_empty_n,
    output   root_V_read,
    output  [31:0] distortion_out_V_din,
    input   distortion_out_V_full_n,
    output   distortion_out_V_write,
    output  [47:0] clusters_out_value_V_din,
    input   clusters_out_value_V_full_n,
    output   clusters_out_value_V_write
);


    wire   ddr_bus_0_0_V_req_din;
    wire   ddr_bus_0_0_V_req_full_n;
    wire   ddr_bus_0_0_V_req_write;
    wire   ddr_bus_0_0_V_rsp_empty_n;
    wire   ddr_bus_0_0_V_rsp_read;
    wire  [31:0] ddr_bus_0_0_V_address;
    wire  [511:0] ddr_bus_0_0_V_datain;
    wire  [511:0] ddr_bus_0_0_V_dataout;
    wire  [31:0] ddr_bus_0_0_V_size;

    wire   ddr_bus_0_1_V_req_din;
    wire   ddr_bus_0_1_V_req_full_n;
    wire   ddr_bus_0_1_V_req_write;
    wire   ddr_bus_0_1_V_rsp_empty_n;
    wire   ddr_bus_0_1_V_rsp_read;
    wire  [31:0] ddr_bus_0_1_V_address;
    wire  [7:0] ddr_bus_0_1_V_datain;
    wire  [7:0] ddr_bus_0_1_V_dataout;
    wire  [31:0] ddr_bus_0_1_V_size;

    wire   ddr_bus_0_2_V_req_din;
    wire   ddr_bus_0_2_V_req_full_n;
    wire   ddr_bus_0_2_V_req_write;
    wire   ddr_bus_0_2_V_rsp_empty_n;
    wire   ddr_bus_0_2_V_rsp_read;
    wire  [31:0] ddr_bus_0_2_V_address;
    wire  [95:0] ddr_bus_0_2_V_datain;
    wire  [95:0] ddr_bus_0_2_V_dataout;
    wire  [31:0] ddr_bus_0_2_V_size;

    wire   ddr_bus_0_3_V_req_din;
    wire   ddr_bus_0_3_V_req_full_n;
    wire   ddr_bus_0_3_V_req_write;
    wire   ddr_bus_0_3_V_rsp_empty_n;
    wire   ddr_bus_0_3_V_rsp_read;
    wire  [31:0] ddr_bus_0_3_V_address;
    wire  [63:0] ddr_bus_0_3_V_datain;
    wire  [63:0] ddr_bus_0_3_V_dataout;
    wire  [31:0] ddr_bus_0_3_V_size;
    wire   int_access_critical_region0;
    wire   int_access_critical_region0_ap_vld;

    wire   ddr_bus_1_0_V_req_din;
    wire   ddr_bus_1_0_V_req_full_n;
    wire   ddr_bus_1_0_V_req_write;
    wire   ddr_bus_1_0_V_rsp_empty_n;
    wire   ddr_bus_1_0_V_rsp_read;
    wire  [31:0] ddr_bus_1_0_V_address;
    wire  [511:0] ddr_bus_1_0_V_datain;
    wire  [511:0] ddr_bus_1_0_V_dataout;
    wire  [31:0] ddr_bus_1_0_V_size;

    wire   ddr_bus_1_1_V_req_din;
    wire   ddr_bus_1_1_V_req_full_n;
    wire   ddr_bus_1_1_V_req_write;
    wire   ddr_bus_1_1_V_rsp_empty_n;
    wire   ddr_bus_1_1_V_rsp_read;
    wire  [31:0] ddr_bus_1_1_V_address;
    wire  [7:0] ddr_bus_1_1_V_datain;
    wire  [7:0] ddr_bus_1_1_V_dataout;
    wire  [31:0] ddr_bus_1_1_V_size;

    wire   ddr_bus_1_2_V_req_din;
    wire   ddr_bus_1_2_V_req_full_n;
    wire   ddr_bus_1_2_V_req_write;
    wire   ddr_bus_1_2_V_rsp_empty_n;
    wire   ddr_bus_1_2_V_rsp_read;
    wire  [31:0] ddr_bus_1_2_V_address;
    wire  [95:0] ddr_bus_1_2_V_datain;
    wire  [95:0] ddr_bus_1_2_V_dataout;
    wire  [31:0] ddr_bus_1_2_V_size;

    wire   ddr_bus_1_3_V_req_din;
    wire   ddr_bus_1_3_V_req_full_n;
    wire   ddr_bus_1_3_V_req_write;
    wire   ddr_bus_1_3_V_rsp_empty_n;
    wire   ddr_bus_1_3_V_rsp_read;
    wire  [31:0] ddr_bus_1_3_V_address;
    wire  [63:0] ddr_bus_1_3_V_datain;
    wire  [63:0] ddr_bus_1_3_V_dataout;
    wire  [31:0] ddr_bus_1_3_V_size;
    wire   int_access_critical_region1;
    wire   int_access_critical_region1_ap_vld;

    wire   ddr_bus_2_0_V_req_din;
    wire   ddr_bus_2_0_V_req_full_n;
    wire   ddr_bus_2_0_V_req_write;
    wire   ddr_bus_2_0_V_rsp_empty_n;
    wire   ddr_bus_2_0_V_rsp_read;
    wire  [31:0] ddr_bus_2_0_V_address;
    wire  [511:0] ddr_bus_2_0_V_datain;
    wire  [511:0] ddr_bus_2_0_V_dataout;
    wire  [31:0] ddr_bus_2_0_V_size;

    wire   ddr_bus_2_1_V_req_din;
    wire   ddr_bus_2_1_V_req_full_n;
    wire   ddr_bus_2_1_V_req_write;
    wire   ddr_bus_2_1_V_rsp_empty_n;
    wire   ddr_bus_2_1_V_rsp_read;
    wire  [31:0] ddr_bus_2_1_V_address;
    wire  [7:0] ddr_bus_2_1_V_datain;
    wire  [7:0] ddr_bus_2_1_V_dataout;
    wire  [31:0] ddr_bus_2_1_V_size;

    wire   ddr_bus_2_2_V_req_din;
    wire   ddr_bus_2_2_V_req_full_n;
    wire   ddr_bus_2_2_V_req_write;
    wire   ddr_bus_2_2_V_rsp_empty_n;
    wire   ddr_bus_2_2_V_rsp_read;
    wire  [31:0] ddr_bus_2_2_V_address;
    wire  [95:0] ddr_bus_2_2_V_datain;
    wire  [95:0] ddr_bus_2_2_V_dataout;
    wire  [31:0] ddr_bus_2_2_V_size;

    wire   ddr_bus_2_3_V_req_din;
    wire   ddr_bus_2_3_V_req_full_n;
    wire   ddr_bus_2_3_V_req_write;
    wire   ddr_bus_2_3_V_rsp_empty_n;
    wire   ddr_bus_2_3_V_rsp_read;
    wire  [31:0] ddr_bus_2_3_V_address;
    wire  [63:0] ddr_bus_2_3_V_datain;
    wire  [63:0] ddr_bus_2_3_V_dataout;
    wire  [31:0] ddr_bus_2_3_V_size;
    wire   int_access_critical_region2;
    wire   int_access_critical_region2_ap_vld;

    wire   ddr_bus_3_0_V_req_din;
    wire   ddr_bus_3_0_V_req_full_n;
    wire   ddr_bus_3_0_V_req_write;
    wire   ddr_bus_3_0_V_rsp_empty_n;
    wire   ddr_bus_3_0_V_rsp_read;
    wire  [31:0] ddr_bus_3_0_V_address;
    wire  [511:0] ddr_bus_3_0_V_datain;
    wire  [511:0] ddr_bus_3_0_V_dataout;
    wire  [31:0] ddr_bus_3_0_V_size;

    wire   ddr_bus_3_1_V_req_din;
    wire   ddr_bus_3_1_V_req_full_n;
    wire   ddr_bus_3_1_V_req_write;
    wire   ddr_bus_3_1_V_rsp_empty_n;
    wire   ddr_bus_3_1_V_rsp_read;
    wire  [31:0] ddr_bus_3_1_V_address;
    wire  [7:0] ddr_bus_3_1_V_datain;
    wire  [7:0] ddr_bus_3_1_V_dataout;
    wire  [31:0] ddr_bus_3_1_V_size;

    wire   ddr_bus_3_2_V_req_din;
    wire   ddr_bus_3_2_V_req_full_n;
    wire   ddr_bus_3_2_V_req_write;
    wire   ddr_bus_3_2_V_rsp_empty_n;
    wire   ddr_bus_3_2_V_rsp_read;
    wire  [31:0] ddr_bus_3_2_V_address;
    wire  [95:0] ddr_bus_3_2_V_datain;
    wire  [95:0] ddr_bus_3_2_V_dataout;
    wire  [31:0] ddr_bus_3_2_V_size;

    wire   ddr_bus_3_3_V_req_din;
    wire   ddr_bus_3_3_V_req_full_n;
    wire   ddr_bus_3_3_V_req_write;
    wire   ddr_bus_3_3_V_rsp_empty_n;
    wire   ddr_bus_3_3_V_rsp_read;
    wire  [31:0] ddr_bus_3_3_V_address;
    wire  [63:0] ddr_bus_3_3_V_datain;
    wire  [63:0] ddr_bus_3_3_V_dataout;
    wire  [31:0] ddr_bus_3_3_V_size;
    wire   int_access_critical_region3;
    wire   int_access_critical_region3_ap_vld;

    wire   freelist_bus_0_1_V_req_din;
    wire   freelist_bus_0_1_V_req_full_n;
    wire   freelist_bus_0_1_V_req_write;
    wire   freelist_bus_0_1_V_rsp_empty_n;
    wire   freelist_bus_0_1_V_rsp_read;
    wire  [31:0] freelist_bus_0_1_V_address;
    wire  [31:0] freelist_bus_0_1_V_datain;
    wire  [31:0] freelist_bus_0_1_V_dataout;
    wire  [31:0] freelist_bus_0_1_V_size;

    wire   freelist_bus_1_1_V_req_din;
    wire   freelist_bus_1_1_V_req_full_n;
    wire   freelist_bus_1_1_V_req_write;
    wire   freelist_bus_1_1_V_rsp_empty_n;
    wire   freelist_bus_1_1_V_rsp_read;
    wire  [31:0] freelist_bus_1_1_V_address;
    wire  [31:0] freelist_bus_1_1_V_datain;
    wire  [31:0] freelist_bus_1_1_V_dataout;
    wire  [31:0] freelist_bus_1_1_V_size;

    wire   freelist_bus_2_1_V_req_din;
    wire   freelist_bus_2_1_V_req_full_n;
    wire   freelist_bus_2_1_V_req_write;
    wire   freelist_bus_2_1_V_rsp_empty_n;
    wire   freelist_bus_2_1_V_rsp_read;
    wire  [31:0] freelist_bus_2_1_V_address;
    wire  [31:0] freelist_bus_2_1_V_datain;
    wire  [31:0] freelist_bus_2_1_V_dataout;
    wire  [31:0] freelist_bus_2_1_V_size;

    wire   freelist_bus_3_1_V_req_din;
    wire   freelist_bus_3_1_V_req_full_n;
    wire   freelist_bus_3_1_V_req_write;
    wire   freelist_bus_3_1_V_rsp_empty_n;
    wire   freelist_bus_3_1_V_rsp_read;
    wire  [31:0] freelist_bus_3_1_V_address;
    wire  [31:0] freelist_bus_3_1_V_datain;
    wire  [31:0] freelist_bus_3_1_V_dataout;
    wire  [31:0] freelist_bus_3_1_V_size;


    filtering_algorithm_top filtering_algorithm_top_U (
        .ap_clk (ap_clk),
        .ap_rst_n (ap_rst_n),
        .ap_start (ap_start),
        .ap_done (ap_done),
        .ap_idle (ap_idle),
        .ap_ready (ap_ready),
        .i_node_data_value_V_dout (i_node_data_value_V_dout),
        .i_node_data_value_V_empty_n (i_node_data_value_V_empty_n),
        .i_node_data_value_V_read (i_node_data_value_V_read),
        .ddr_bus_0_0_value_V_req_din (ddr_bus_0_0_V_req_din),
        .ddr_bus_0_0_value_V_req_full_n (ddr_bus_0_0_V_req_full_n),
        .ddr_bus_0_0_value_V_req_write (ddr_bus_0_0_V_req_write),
        .ddr_bus_0_0_value_V_rsp_empty_n (ddr_bus_0_0_V_rsp_empty_n),
        .ddr_bus_0_0_value_V_rsp_read (ddr_bus_0_0_V_rsp_read),
        .ddr_bus_0_0_value_V_address (ddr_bus_0_0_V_address),
        .ddr_bus_0_0_value_V_datain (ddr_bus_0_0_V_datain),
        .ddr_bus_0_0_value_V_dataout (ddr_bus_0_0_V_dataout),
        .ddr_bus_0_0_value_V_size (ddr_bus_0_0_V_size),
        .ddr_bus_0_1_V_req_din (ddr_bus_0_1_V_req_din),
        .ddr_bus_0_1_V_req_full_n (ddr_bus_0_1_V_req_full_n),
        .ddr_bus_0_1_V_req_write (ddr_bus_0_1_V_req_write),
        .ddr_bus_0_1_V_rsp_empty_n (ddr_bus_0_1_V_rsp_empty_n),
        .ddr_bus_0_1_V_rsp_read (ddr_bus_0_1_V_rsp_read),
        .ddr_bus_0_1_V_address (ddr_bus_0_1_V_address),
        .ddr_bus_0_1_V_datain (ddr_bus_0_1_V_datain),
        .ddr_bus_0_1_V_dataout (ddr_bus_0_1_V_dataout),
        .ddr_bus_0_1_V_size (ddr_bus_0_1_V_size),
        .ddr_bus_0_2_value_V_req_din (ddr_bus_0_2_V_req_din),
        .ddr_bus_0_2_value_V_req_full_n (ddr_bus_0_2_V_req_full_n),
        .ddr_bus_0_2_value_V_req_write (ddr_bus_0_2_V_req_write),
        .ddr_bus_0_2_value_V_rsp_empty_n (ddr_bus_0_2_V_rsp_empty_n),
        .ddr_bus_0_2_value_V_rsp_read (ddr_bus_0_2_V_rsp_read),
        .ddr_bus_0_2_value_V_address (ddr_bus_0_2_V_address),
        .ddr_bus_0_2_value_V_datain (ddr_bus_0_2_V_datain),
        .ddr_bus_0_2_value_V_dataout (ddr_bus_0_2_V_dataout),
        .ddr_bus_0_2_value_V_size (ddr_bus_0_2_V_size),
        .ddr_bus_0_3_V_req_din (ddr_bus_0_3_V_req_din),
        .ddr_bus_0_3_V_req_full_n (ddr_bus_0_3_V_req_full_n),
        .ddr_bus_0_3_V_req_write (ddr_bus_0_3_V_req_write),
        .ddr_bus_0_3_V_rsp_empty_n (ddr_bus_0_3_V_rsp_empty_n),
        .ddr_bus_0_3_V_rsp_read (ddr_bus_0_3_V_rsp_read),
        .ddr_bus_0_3_V_address (ddr_bus_0_3_V_address),
        .ddr_bus_0_3_V_datain (ddr_bus_0_3_V_datain),
        .ddr_bus_0_3_V_dataout (ddr_bus_0_3_V_dataout),
        .ddr_bus_0_3_V_size (ddr_bus_0_3_V_size),
        .access_critical_region0 (access_critical_region0),
        .access_critical_region0_ap_vld (access_critical_region0_ap_vld),
        .ddr_bus_1_0_value_V_req_din (ddr_bus_1_0_V_req_din),
        .ddr_bus_1_0_value_V_req_full_n (ddr_bus_1_0_V_req_full_n),
        .ddr_bus_1_0_value_V_req_write (ddr_bus_1_0_V_req_write),
        .ddr_bus_1_0_value_V_rsp_empty_n (ddr_bus_1_0_V_rsp_empty_n),
        .ddr_bus_1_0_value_V_rsp_read (ddr_bus_1_0_V_rsp_read),
        .ddr_bus_1_0_value_V_address (ddr_bus_1_0_V_address),
        .ddr_bus_1_0_value_V_datain (ddr_bus_1_0_V_datain),
        .ddr_bus_1_0_value_V_dataout (ddr_bus_1_0_V_dataout),
        .ddr_bus_1_0_value_V_size (ddr_bus_1_0_V_size),
        .ddr_bus_1_1_V_req_din (ddr_bus_1_1_V_req_din),
        .ddr_bus_1_1_V_req_full_n (ddr_bus_1_1_V_req_full_n),
        .ddr_bus_1_1_V_req_write (ddr_bus_1_1_V_req_write),
        .ddr_bus_1_1_V_rsp_empty_n (ddr_bus_1_1_V_rsp_empty_n),
        .ddr_bus_1_1_V_rsp_read (ddr_bus_1_1_V_rsp_read),
        .ddr_bus_1_1_V_address (ddr_bus_1_1_V_address),
        .ddr_bus_1_1_V_datain (ddr_bus_1_1_V_datain),
        .ddr_bus_1_1_V_dataout (ddr_bus_1_1_V_dataout),
        .ddr_bus_1_1_V_size (ddr_bus_1_1_V_size),
        .ddr_bus_1_2_value_V_req_din (ddr_bus_1_2_V_req_din),
        .ddr_bus_1_2_value_V_req_full_n (ddr_bus_1_2_V_req_full_n),
        .ddr_bus_1_2_value_V_req_write (ddr_bus_1_2_V_req_write),
        .ddr_bus_1_2_value_V_rsp_empty_n (ddr_bus_1_2_V_rsp_empty_n),
        .ddr_bus_1_2_value_V_rsp_read (ddr_bus_1_2_V_rsp_read),
        .ddr_bus_1_2_value_V_address (ddr_bus_1_2_V_address),
        .ddr_bus_1_2_value_V_datain (ddr_bus_1_2_V_datain),
        .ddr_bus_1_2_value_V_dataout (ddr_bus_1_2_V_dataout),
        .ddr_bus_1_2_value_V_size (ddr_bus_1_2_V_size),
        .ddr_bus_1_3_V_req_din (ddr_bus_1_3_V_req_din),
        .ddr_bus_1_3_V_req_full_n (ddr_bus_1_3_V_req_full_n),
        .ddr_bus_1_3_V_req_write (ddr_bus_1_3_V_req_write),
        .ddr_bus_1_3_V_rsp_empty_n (ddr_bus_1_3_V_rsp_empty_n),
        .ddr_bus_1_3_V_rsp_read (ddr_bus_1_3_V_rsp_read),
        .ddr_bus_1_3_V_address (ddr_bus_1_3_V_address),
        .ddr_bus_1_3_V_datain (ddr_bus_1_3_V_datain),
        .ddr_bus_1_3_V_dataout (ddr_bus_1_3_V_dataout),
        .ddr_bus_1_3_V_size (ddr_bus_1_3_V_size),
        `ifndef REDUCE_PAR_TO_1
        .access_critical_region1 (access_critical_region1),
        .access_critical_region1_ap_vld (access_critical_region1_ap_vld),
        `endif
        .ddr_bus_2_0_value_V_req_din (ddr_bus_2_0_V_req_din),
        .ddr_bus_2_0_value_V_req_full_n (ddr_bus_2_0_V_req_full_n),
        .ddr_bus_2_0_value_V_req_write (ddr_bus_2_0_V_req_write),
        .ddr_bus_2_0_value_V_rsp_empty_n (ddr_bus_2_0_V_rsp_empty_n),
        .ddr_bus_2_0_value_V_rsp_read (ddr_bus_2_0_V_rsp_read),
        .ddr_bus_2_0_value_V_address (ddr_bus_2_0_V_address),
        .ddr_bus_2_0_value_V_datain (ddr_bus_2_0_V_datain),
        .ddr_bus_2_0_value_V_dataout (ddr_bus_2_0_V_dataout),
        .ddr_bus_2_0_value_V_size (ddr_bus_2_0_V_size),
        .ddr_bus_2_1_V_req_din (ddr_bus_2_1_V_req_din),
        .ddr_bus_2_1_V_req_full_n (ddr_bus_2_1_V_req_full_n),
        .ddr_bus_2_1_V_req_write (ddr_bus_2_1_V_req_write),
        .ddr_bus_2_1_V_rsp_empty_n (ddr_bus_2_1_V_rsp_empty_n),
        .ddr_bus_2_1_V_rsp_read (ddr_bus_2_1_V_rsp_read),
        .ddr_bus_2_1_V_address (ddr_bus_2_1_V_address),
        .ddr_bus_2_1_V_datain (ddr_bus_2_1_V_datain),
        .ddr_bus_2_1_V_dataout (ddr_bus_2_1_V_dataout),
        .ddr_bus_2_1_V_size (ddr_bus_2_1_V_size),
        .ddr_bus_2_2_value_V_req_din (ddr_bus_2_2_V_req_din),
        .ddr_bus_2_2_value_V_req_full_n (ddr_bus_2_2_V_req_full_n),
        .ddr_bus_2_2_value_V_req_write (ddr_bus_2_2_V_req_write),
        .ddr_bus_2_2_value_V_rsp_empty_n (ddr_bus_2_2_V_rsp_empty_n),
        .ddr_bus_2_2_value_V_rsp_read (ddr_bus_2_2_V_rsp_read),
        .ddr_bus_2_2_value_V_address (ddr_bus_2_2_V_address),
        .ddr_bus_2_2_value_V_datain (ddr_bus_2_2_V_datain),
        .ddr_bus_2_2_value_V_dataout (ddr_bus_2_2_V_dataout),
        .ddr_bus_2_2_value_V_size (ddr_bus_2_2_V_size),
        .ddr_bus_2_3_V_req_din (ddr_bus_2_3_V_req_din),
        .ddr_bus_2_3_V_req_full_n (ddr_bus_2_3_V_req_full_n),
        .ddr_bus_2_3_V_req_write (ddr_bus_2_3_V_req_write),
        .ddr_bus_2_3_V_rsp_empty_n (ddr_bus_2_3_V_rsp_empty_n),
        .ddr_bus_2_3_V_rsp_read (ddr_bus_2_3_V_rsp_read),
        .ddr_bus_2_3_V_address (ddr_bus_2_3_V_address),
        .ddr_bus_2_3_V_datain (ddr_bus_2_3_V_datain),
        .ddr_bus_2_3_V_dataout (ddr_bus_2_3_V_dataout),
        .ddr_bus_2_3_V_size (ddr_bus_2_3_V_size),
        `ifndef REDUCE_PAR_TO_2
        `ifndef REDUCE_PAR_TO_1
        .access_critical_region2 (access_critical_region2),
        .access_critical_region2_ap_vld (access_critical_region2_ap_vld),
        `endif
        `endif
        .ddr_bus_3_0_value_V_req_din (ddr_bus_3_0_V_req_din),
        .ddr_bus_3_0_value_V_req_full_n (ddr_bus_3_0_V_req_full_n),
        .ddr_bus_3_0_value_V_req_write (ddr_bus_3_0_V_req_write),
        .ddr_bus_3_0_value_V_rsp_empty_n (ddr_bus_3_0_V_rsp_empty_n),
        .ddr_bus_3_0_value_V_rsp_read (ddr_bus_3_0_V_rsp_read),
        .ddr_bus_3_0_value_V_address (ddr_bus_3_0_V_address),
        .ddr_bus_3_0_value_V_datain (ddr_bus_3_0_V_datain),
        .ddr_bus_3_0_value_V_dataout (ddr_bus_3_0_V_dataout),
        .ddr_bus_3_0_value_V_size (ddr_bus_3_0_V_size),
        .ddr_bus_3_1_V_req_din (ddr_bus_3_1_V_req_din),
        .ddr_bus_3_1_V_req_full_n (ddr_bus_3_1_V_req_full_n),
        .ddr_bus_3_1_V_req_write (ddr_bus_3_1_V_req_write),
        .ddr_bus_3_1_V_rsp_empty_n (ddr_bus_3_1_V_rsp_empty_n),
        .ddr_bus_3_1_V_rsp_read (ddr_bus_3_1_V_rsp_read),
        .ddr_bus_3_1_V_address (ddr_bus_3_1_V_address),
        .ddr_bus_3_1_V_datain (ddr_bus_3_1_V_datain),
        .ddr_bus_3_1_V_dataout (ddr_bus_3_1_V_dataout),
        .ddr_bus_3_1_V_size (ddr_bus_3_1_V_size),
        .ddr_bus_3_2_value_V_req_din (ddr_bus_3_2_V_req_din),
        .ddr_bus_3_2_value_V_req_full_n (ddr_bus_3_2_V_req_full_n),
        .ddr_bus_3_2_value_V_req_write (ddr_bus_3_2_V_req_write),
        .ddr_bus_3_2_value_V_rsp_empty_n (ddr_bus_3_2_V_rsp_empty_n),
        .ddr_bus_3_2_value_V_rsp_read (ddr_bus_3_2_V_rsp_read),
        .ddr_bus_3_2_value_V_address (ddr_bus_3_2_V_address),
        .ddr_bus_3_2_value_V_datain (ddr_bus_3_2_V_datain),
        .ddr_bus_3_2_value_V_dataout (ddr_bus_3_2_V_dataout),
        .ddr_bus_3_2_value_V_size (ddr_bus_3_2_V_size),
        .ddr_bus_3_3_V_req_din (ddr_bus_3_3_V_req_din),
        .ddr_bus_3_3_V_req_full_n (ddr_bus_3_3_V_req_full_n),
        .ddr_bus_3_3_V_req_write (ddr_bus_3_3_V_req_write),
        .ddr_bus_3_3_V_rsp_empty_n (ddr_bus_3_3_V_rsp_empty_n),
        .ddr_bus_3_3_V_rsp_read (ddr_bus_3_3_V_rsp_read),
        .ddr_bus_3_3_V_address (ddr_bus_3_3_V_address),
        .ddr_bus_3_3_V_datain (ddr_bus_3_3_V_datain),
        .ddr_bus_3_3_V_dataout (ddr_bus_3_3_V_dataout),
        .ddr_bus_3_3_V_size (ddr_bus_3_3_V_size),
        `ifndef REDUCE_PAR_TO_2
        `ifndef REDUCE_PAR_TO_1
        .access_critical_region3 (access_critical_region3),
        .access_critical_region3_ap_vld (access_critical_region3_ap_vld),
        `endif
        `endif
        .freelist_bus_0_1_V_req_din (freelist_bus_0_1_V_req_din),
        .freelist_bus_0_1_V_req_full_n (freelist_bus_0_1_V_req_full_n),
        .freelist_bus_0_1_V_req_write (freelist_bus_0_1_V_req_write),
        .freelist_bus_0_1_V_rsp_empty_n (freelist_bus_0_1_V_rsp_empty_n),
        .freelist_bus_0_1_V_rsp_read (freelist_bus_0_1_V_rsp_read),
        .freelist_bus_0_1_V_address (freelist_bus_0_1_V_address),
        .freelist_bus_0_1_V_datain (freelist_bus_0_1_V_datain),
        .freelist_bus_0_1_V_dataout (freelist_bus_0_1_V_dataout),
        .freelist_bus_0_1_V_size (freelist_bus_0_1_V_size),
        .freelist_bus_1_1_V_req_din (freelist_bus_1_1_V_req_din),
        .freelist_bus_1_1_V_req_full_n (freelist_bus_1_1_V_req_full_n),
        .freelist_bus_1_1_V_req_write (freelist_bus_1_1_V_req_write),
        .freelist_bus_1_1_V_rsp_empty_n (freelist_bus_1_1_V_rsp_empty_n),
        .freelist_bus_1_1_V_rsp_read (freelist_bus_1_1_V_rsp_read),
        .freelist_bus_1_1_V_address (freelist_bus_1_1_V_address),
        .freelist_bus_1_1_V_datain (freelist_bus_1_1_V_datain),
        .freelist_bus_1_1_V_dataout (freelist_bus_1_1_V_dataout),
        .freelist_bus_1_1_V_size (freelist_bus_1_1_V_size),
        .freelist_bus_2_1_V_req_din (freelist_bus_2_1_V_req_din),
        .freelist_bus_2_1_V_req_full_n (freelist_bus_2_1_V_req_full_n),
        .freelist_bus_2_1_V_req_write (freelist_bus_2_1_V_req_write),
        .freelist_bus_2_1_V_rsp_empty_n (freelist_bus_2_1_V_rsp_empty_n),
        .freelist_bus_2_1_V_rsp_read (freelist_bus_2_1_V_rsp_read),
        .freelist_bus_2_1_V_address (freelist_bus_2_1_V_address),
        .freelist_bus_2_1_V_datain (freelist_bus_2_1_V_datain),
        .freelist_bus_2_1_V_dataout (freelist_bus_2_1_V_dataout),
        .freelist_bus_2_1_V_size (freelist_bus_2_1_V_size),
        .freelist_bus_3_1_V_req_din (freelist_bus_3_1_V_req_din),
        .freelist_bus_3_1_V_req_full_n (freelist_bus_3_1_V_req_full_n),
        .freelist_bus_3_1_V_req_write (freelist_bus_3_1_V_req_write),
        .freelist_bus_3_1_V_rsp_empty_n (freelist_bus_3_1_V_rsp_empty_n),
        .freelist_bus_3_1_V_rsp_read (freelist_bus_3_1_V_rsp_read),
        .freelist_bus_3_1_V_address (freelist_bus_3_1_V_address),
        .freelist_bus_3_1_V_datain (freelist_bus_3_1_V_datain),
        .freelist_bus_3_1_V_dataout (freelist_bus_3_1_V_dataout),
        .freelist_bus_3_1_V_size (freelist_bus_3_1_V_size),
        .cntr_pos_init_value_V_dout (cntr_pos_init_value_V_dout),
        .cntr_pos_init_value_V_empty_n (cntr_pos_init_value_V_empty_n),
        .cntr_pos_init_value_V_read (cntr_pos_init_value_V_read),
        .n_V (n_V),
        .k_V (k_V),
        .l (l),
        .root_V_dout (root_V_dout),
        .root_V_empty_n (root_V_empty_n),
        .root_V_read (root_V_read),
        .distortion_out_V_din (distortion_out_V_din),
        .distortion_out_V_full_n (distortion_out_V_full_n),
        .distortion_out_V_write (distortion_out_V_write),
        .clusters_out_value_V_din (clusters_out_value_V_din),
        .clusters_out_value_V_full_n (clusters_out_value_V_full_n),
        .clusters_out_value_V_write (clusters_out_value_V_write)
    );


    bus_bridge #(
         .DATA_WIDTH ( 512 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U0_0 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (ddr_bus_0_0_V_rsp_empty_n),    
        .rsp_full_n (ddr_bus_0_0_V_req_full_n),
        .req_write (ddr_bus_0_0_V_req_write),
        .req_din (ddr_bus_0_0_V_req_din),
        .rsp_read (ddr_bus_0_0_V_rsp_read),
        .address (ddr_bus_0_0_V_address),
        .size (ddr_bus_0_0_V_size),
        .dataout (ddr_bus_0_0_V_dataout),
        .datain (ddr_bus_0_0_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq0_0),
        .writeReq_data (writeReq_data0_0),
        .writeReq_addr (writeReq_addr0_0),
        .writeAck (writeAck0_0),
        .readReq (readReq0_0),
        .readReq_addr (readReq_addr0_0),
        .readAck (readAck0_0),
        .readReq_data (readReq_data0_0)
    );

    bus_bridge #(
         .DATA_WIDTH ( 8 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U0_1 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (ddr_bus_0_1_V_rsp_empty_n),    
        .rsp_full_n (ddr_bus_0_1_V_req_full_n),
        .req_write (ddr_bus_0_1_V_req_write),
        .req_din (ddr_bus_0_1_V_req_din),
        .rsp_read (ddr_bus_0_1_V_rsp_read),
        .address (ddr_bus_0_1_V_address),
        .size (ddr_bus_0_1_V_size),
        .dataout (ddr_bus_0_1_V_dataout),
        .datain (ddr_bus_0_1_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq0_1),
        .writeReq_data (writeReq_data0_1),
        .writeReq_addr (writeReq_addr0_1),
        .writeAck (writeAck0_1),
        .readReq (readReq0_1),
        .readReq_addr (readReq_addr0_1),
        .readAck (readAck0_1),
        .readReq_data (readReq_data0_1)
    );

    bus_bridge #(
         .DATA_WIDTH ( 96 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U0_2 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (ddr_bus_0_2_V_rsp_empty_n),    
        .rsp_full_n (ddr_bus_0_2_V_req_full_n),
        .req_write (ddr_bus_0_2_V_req_write),
        .req_din (ddr_bus_0_2_V_req_din),
        .rsp_read (ddr_bus_0_2_V_rsp_read),
        .address (ddr_bus_0_2_V_address),
        .size (ddr_bus_0_2_V_size),
        .dataout (ddr_bus_0_2_V_dataout),
        .datain (ddr_bus_0_2_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq0_2),
        .writeReq_data (writeReq_data0_2),
        .writeReq_addr (writeReq_addr0_2),
        .writeAck (writeAck0_2),
        .readReq (readReq0_2),
        .readReq_addr (readReq_addr0_2),
        .readAck (readAck0_2),
        .readReq_data (readReq_data0_2)
    );


    bus_bridge #(
         .DATA_WIDTH ( 32 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U0_4 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (freelist_bus_0_1_V_rsp_empty_n),    
        .rsp_full_n (freelist_bus_0_1_V_req_full_n),
        .req_write (freelist_bus_0_1_V_req_write),
        .req_din (freelist_bus_0_1_V_req_din),
        .rsp_read (freelist_bus_0_1_V_rsp_read),
        .address (freelist_bus_0_1_V_address),
        .size (freelist_bus_0_1_V_size),
        .dataout (freelist_bus_0_1_V_dataout),
        .datain (freelist_bus_0_1_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq0_4),
        .writeReq_data (writeReq_data0_4),
        .writeReq_addr (writeReq_addr0_4),
        .writeAck (writeAck0_4),
        .readReq (readReq0_4),
        .readReq_addr (readReq_addr0_4),
        .readAck (readAck0_4),
        .readReq_data (readReq_data0_4)
    );


   `ifndef CENTRE_BUFFER_ONCHIP
    bus_bridge #(
         .DATA_WIDTH ( 64 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U0_3 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (ddr_bus_0_3_V_rsp_empty_n),    
        .rsp_full_n (ddr_bus_0_3_V_req_full_n),
        .req_write (ddr_bus_0_3_V_req_write),
        .req_din (ddr_bus_0_3_V_req_din),
        .rsp_read (ddr_bus_0_3_V_rsp_read),
        .address (ddr_bus_0_3_V_address),
        .size (ddr_bus_0_3_V_size),
        .dataout (ddr_bus_0_3_V_dataout),
        .datain (ddr_bus_0_3_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq0_3),
        .writeReq_data (writeReq_data0_3),
        .writeReq_addr (writeReq_addr0_3),
        .writeAck (writeAck0_3),
        .readReq (readReq0_3),
        .readReq_addr (readReq_addr0_3),
        .readAck (readAck0_3),
        .readReq_data (readReq_data0_3)
    );

    `endif


    `ifndef REDUCE_PAR_TO_1

    bus_bridge #(
         .DATA_WIDTH ( 512 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U1_0 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (ddr_bus_1_0_V_rsp_empty_n),    
        .rsp_full_n (ddr_bus_1_0_V_req_full_n),
        .req_write (ddr_bus_1_0_V_req_write),
        .req_din (ddr_bus_1_0_V_req_din),
        .rsp_read (ddr_bus_1_0_V_rsp_read),
        .address (ddr_bus_1_0_V_address),
        .size (ddr_bus_1_0_V_size),
        .dataout (ddr_bus_1_0_V_dataout),
        .datain (ddr_bus_1_0_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq1_0),
        .writeReq_data (writeReq_data1_0),
        .writeReq_addr (writeReq_addr1_0),
        .writeAck (writeAck1_0),
        .readReq (readReq1_0),
        .readReq_addr (readReq_addr1_0),
        .readAck (readAck1_0),
        .readReq_data (readReq_data1_0)
    );

    bus_bridge #(
         .DATA_WIDTH ( 8 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U1_1 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (ddr_bus_1_1_V_rsp_empty_n),    
        .rsp_full_n (ddr_bus_1_1_V_req_full_n),
        .req_write (ddr_bus_1_1_V_req_write),
        .req_din (ddr_bus_1_1_V_req_din),
        .rsp_read (ddr_bus_1_1_V_rsp_read),
        .address (ddr_bus_1_1_V_address),
        .size (ddr_bus_1_1_V_size),
        .dataout (ddr_bus_1_1_V_dataout),
        .datain (ddr_bus_1_1_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq1_1),
        .writeReq_data (writeReq_data1_1),
        .writeReq_addr (writeReq_addr1_1),
        .writeAck (writeAck1_1),
        .readReq (readReq1_1),
        .readReq_addr (readReq_addr1_1),
        .readAck (readAck1_1),
        .readReq_data (readReq_data1_1)
    );

    bus_bridge #(
         .DATA_WIDTH ( 96 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U1_2 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (ddr_bus_1_2_V_rsp_empty_n),    
        .rsp_full_n (ddr_bus_1_2_V_req_full_n),
        .req_write (ddr_bus_1_2_V_req_write),
        .req_din (ddr_bus_1_2_V_req_din),
        .rsp_read (ddr_bus_1_2_V_rsp_read),
        .address (ddr_bus_1_2_V_address),
        .size (ddr_bus_1_2_V_size),
        .dataout (ddr_bus_1_2_V_dataout),
        .datain (ddr_bus_1_2_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq1_2),
        .writeReq_data (writeReq_data1_2),
        .writeReq_addr (writeReq_addr1_2),
        .writeAck (writeAck1_2),
        .readReq (readReq1_2),
        .readReq_addr (readReq_addr1_2),
        .readAck (readAck1_2),
        .readReq_data (readReq_data1_2)
    );


    bus_bridge #(
         .DATA_WIDTH ( 32 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U1_4 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (freelist_bus_1_1_V_rsp_empty_n),    
        .rsp_full_n (freelist_bus_1_1_V_req_full_n),
        .req_write (freelist_bus_1_1_V_req_write),
        .req_din (freelist_bus_1_1_V_req_din),
        .rsp_read (freelist_bus_1_1_V_rsp_read),
        .address (freelist_bus_1_1_V_address),
        .size (freelist_bus_1_1_V_size),
        .dataout (freelist_bus_1_1_V_dataout),
        .datain (freelist_bus_1_1_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq1_4),
        .writeReq_data (writeReq_data1_4),
        .writeReq_addr (writeReq_addr1_4),
        .writeAck (writeAck1_4),
        .readReq (readReq1_4),
        .readReq_addr (readReq_addr1_4),
        .readAck (readAck1_4),
        .readReq_data (readReq_data1_4)
    );
    
   `ifndef CENTRE_BUFFER_ONCHIP
    bus_bridge #(
         .DATA_WIDTH ( 64 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U1_3 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (ddr_bus_1_3_V_rsp_empty_n),    
        .rsp_full_n (ddr_bus_1_3_V_req_full_n),
        .req_write (ddr_bus_1_3_V_req_write),
        .req_din (ddr_bus_1_3_V_req_din),
        .rsp_read (ddr_bus_1_3_V_rsp_read),
        .address (ddr_bus_1_3_V_address),
        .size (ddr_bus_1_3_V_size),
        .dataout (ddr_bus_1_3_V_dataout),
        .datain (ddr_bus_1_3_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq1_3),
        .writeReq_data (writeReq_data1_3),
        .writeReq_addr (writeReq_addr1_3),
        .writeAck (writeAck1_3),
        .readReq (readReq1_3),
        .readReq_addr (readReq_addr1_3),
        .readAck (readAck1_3),
        .readReq_data (readReq_data1_3)
    );

    `endif


    `ifndef REDUCE_PAR_TO_2

    bus_bridge #(
         .DATA_WIDTH ( 512 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U2_0 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (ddr_bus_2_0_V_rsp_empty_n),    
        .rsp_full_n (ddr_bus_2_0_V_req_full_n),
        .req_write (ddr_bus_2_0_V_req_write),
        .req_din (ddr_bus_2_0_V_req_din),
        .rsp_read (ddr_bus_2_0_V_rsp_read),
        .address (ddr_bus_2_0_V_address),
        .size (ddr_bus_2_0_V_size),
        .dataout (ddr_bus_2_0_V_dataout),
        .datain (ddr_bus_2_0_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq2_0),
        .writeReq_data (writeReq_data2_0),
        .writeReq_addr (writeReq_addr2_0),
        .writeAck (writeAck2_0),
        .readReq (readReq2_0),
        .readReq_addr (readReq_addr2_0),
        .readAck (readAck2_0),
        .readReq_data (readReq_data2_0)
    );

    bus_bridge #(
         .DATA_WIDTH ( 8 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U2_1 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (ddr_bus_2_1_V_rsp_empty_n),    
        .rsp_full_n (ddr_bus_2_1_V_req_full_n),
        .req_write (ddr_bus_2_1_V_req_write),
        .req_din (ddr_bus_2_1_V_req_din),
        .rsp_read (ddr_bus_2_1_V_rsp_read),
        .address (ddr_bus_2_1_V_address),
        .size (ddr_bus_2_1_V_size),
        .dataout (ddr_bus_2_1_V_dataout),
        .datain (ddr_bus_2_1_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq2_1),
        .writeReq_data (writeReq_data2_1),
        .writeReq_addr (writeReq_addr2_1),
        .writeAck (writeAck2_1),
        .readReq (readReq2_1),
        .readReq_addr (readReq_addr2_1),
        .readAck (readAck2_1),
        .readReq_data (readReq_data2_1)
    );

    bus_bridge #(
         .DATA_WIDTH ( 96 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U2_2 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (ddr_bus_2_2_V_rsp_empty_n),    
        .rsp_full_n (ddr_bus_2_2_V_req_full_n),
        .req_write (ddr_bus_2_2_V_req_write),
        .req_din (ddr_bus_2_2_V_req_din),
        .rsp_read (ddr_bus_2_2_V_rsp_read),
        .address (ddr_bus_2_2_V_address),
        .size (ddr_bus_2_2_V_size),
        .dataout (ddr_bus_2_2_V_dataout),
        .datain (ddr_bus_2_2_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq2_2),
        .writeReq_data (writeReq_data2_2),
        .writeReq_addr (writeReq_addr2_2),
        .writeAck (writeAck2_2),
        .readReq (readReq2_2),
        .readReq_addr (readReq_addr2_2),
        .readAck (readAck2_2),
        .readReq_data (readReq_data2_2)
    );

    bus_bridge #(
         .DATA_WIDTH ( 32 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U2_4 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (freelist_bus_2_1_V_rsp_empty_n),    
        .rsp_full_n (freelist_bus_2_1_V_req_full_n),
        .req_write (freelist_bus_2_1_V_req_write),
        .req_din (freelist_bus_2_1_V_req_din),
        .rsp_read (freelist_bus_2_1_V_rsp_read),
        .address (freelist_bus_2_1_V_address),
        .size (freelist_bus_2_1_V_size),
        .dataout (freelist_bus_2_1_V_dataout),
        .datain (freelist_bus_2_1_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq2_4),
        .writeReq_data (writeReq_data2_4),
        .writeReq_addr (writeReq_addr2_4),
        .writeAck (writeAck2_4),
        .readReq (readReq2_4),
        .readReq_addr (readReq_addr2_4),
        .readAck (readAck2_4),
        .readReq_data (readReq_data2_4)
    );

   `ifndef CENTRE_BUFFER_ONCHIP
    bus_bridge #(
         .DATA_WIDTH ( 64 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U2_3 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (ddr_bus_2_3_V_rsp_empty_n),    
        .rsp_full_n (ddr_bus_2_3_V_req_full_n),
        .req_write (ddr_bus_2_3_V_req_write),
        .req_din (ddr_bus_2_3_V_req_din),
        .rsp_read (ddr_bus_2_3_V_rsp_read),
        .address (ddr_bus_2_3_V_address),
        .size (ddr_bus_2_3_V_size),
        .dataout (ddr_bus_2_3_V_dataout),
        .datain (ddr_bus_2_3_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq2_3),
        .writeReq_data (writeReq_data2_3),
        .writeReq_addr (writeReq_addr2_3),
        .writeAck (writeAck2_3),
        .readReq (readReq2_3),
        .readReq_addr (readReq_addr2_3),
        .readAck (readAck2_3),
        .readReq_data (readReq_data2_3)
    );

    `endif


    bus_bridge #(
         .DATA_WIDTH ( 512 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U3_0 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (ddr_bus_3_0_V_rsp_empty_n),    
        .rsp_full_n (ddr_bus_3_0_V_req_full_n),
        .req_write (ddr_bus_3_0_V_req_write),
        .req_din (ddr_bus_3_0_V_req_din),
        .rsp_read (ddr_bus_3_0_V_rsp_read),
        .address (ddr_bus_3_0_V_address),
        .size (ddr_bus_3_0_V_size),
        .dataout (ddr_bus_3_0_V_dataout),
        .datain (ddr_bus_3_0_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq3_0),
        .writeReq_data (writeReq_data3_0),
        .writeReq_addr (writeReq_addr3_0),
        .writeAck (writeAck3_0),
        .readReq (readReq3_0),
        .readReq_addr (readReq_addr3_0),
        .readAck (readAck3_0),
        .readReq_data (readReq_data3_0)
    );

    bus_bridge #(
         .DATA_WIDTH ( 8 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U3_1 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (ddr_bus_3_1_V_rsp_empty_n),    
        .rsp_full_n (ddr_bus_3_1_V_req_full_n),
        .req_write (ddr_bus_3_1_V_req_write),
        .req_din (ddr_bus_3_1_V_req_din),
        .rsp_read (ddr_bus_3_1_V_rsp_read),
        .address (ddr_bus_3_1_V_address),
        .size (ddr_bus_3_1_V_size),
        .dataout (ddr_bus_3_1_V_dataout),
        .datain (ddr_bus_3_1_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq3_1),
        .writeReq_data (writeReq_data3_1),
        .writeReq_addr (writeReq_addr3_1),
        .writeAck (writeAck3_1),
        .readReq (readReq3_1),
        .readReq_addr (readReq_addr3_1),
        .readAck (readAck3_1),
        .readReq_data (readReq_data3_1)
    );

    bus_bridge #(
         .DATA_WIDTH ( 96 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U3_2 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (ddr_bus_3_2_V_rsp_empty_n),    
        .rsp_full_n (ddr_bus_3_2_V_req_full_n),
        .req_write (ddr_bus_3_2_V_req_write),
        .req_din (ddr_bus_3_2_V_req_din),
        .rsp_read (ddr_bus_3_2_V_rsp_read),
        .address (ddr_bus_3_2_V_address),
        .size (ddr_bus_3_2_V_size),
        .dataout (ddr_bus_3_2_V_dataout),
        .datain (ddr_bus_3_2_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq3_2),
        .writeReq_data (writeReq_data3_2),
        .writeReq_addr (writeReq_addr3_2),
        .writeAck (writeAck3_2),
        .readReq (readReq3_2),
        .readReq_addr (readReq_addr3_2),
        .readAck (readAck3_2),
        .readReq_data (readReq_data3_2)
    );

    bus_bridge #(
         .DATA_WIDTH ( 32 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U3_4 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (freelist_bus_3_1_V_rsp_empty_n),    
        .rsp_full_n (freelist_bus_3_1_V_req_full_n),
        .req_write (freelist_bus_3_1_V_req_write),
        .req_din (freelist_bus_3_1_V_req_din),
        .rsp_read (freelist_bus_3_1_V_rsp_read),
        .address (freelist_bus_3_1_V_address),
        .size (freelist_bus_3_1_V_size),
        .dataout (freelist_bus_3_1_V_dataout),
        .datain (freelist_bus_3_1_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq3_4),
        .writeReq_data (writeReq_data3_4),
        .writeReq_addr (writeReq_addr3_4),
        .writeAck (writeAck3_4),
        .readReq (readReq3_4),
        .readReq_addr (readReq_addr3_4),
        .readAck (readAck3_4),
        .readReq_data (readReq_data3_4)
    );

   `ifndef CENTRE_BUFFER_ONCHIP
    bus_bridge #(
         .DATA_WIDTH ( 64 ),
         .ADDR_WIDTH ( 32 )
    ) 
    bus_bridge_U3_3 (
        .clk (ap_clk),
        .rst_n (ap_rst_n),
        // interface to the HLS core    
        .rsp_empty_n (ddr_bus_3_3_V_rsp_empty_n),    
        .rsp_full_n (ddr_bus_3_3_V_req_full_n),
        .req_write (ddr_bus_3_3_V_req_write),
        .req_din (ddr_bus_3_3_V_req_din),
        .rsp_read (ddr_bus_3_3_V_rsp_read),
        .address (ddr_bus_3_3_V_address),
        .size (ddr_bus_3_3_V_size),
        .dataout (ddr_bus_3_3_V_dataout),
        .datain (ddr_bus_3_3_V_datain),
        // req/resp/write interface to leap    
        .writeReq (writeReq3_3),
        .writeReq_data (writeReq_data3_3),
        .writeReq_addr (writeReq_addr3_3),
        .writeAck (writeAck3_3),
        .readReq (readReq3_3),
        .readReq_addr (readReq_addr3_3),
        .readAck (readAck3_3),
        .readReq_data (readReq_data3_3)
    );

    `endif
    `endif
    `endif


endmodule
